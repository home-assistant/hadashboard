#!/usr/bin/python3

import json
import sys
import traceback
import re
import requests
from configobj import ConfigObj
import datetime
import argparse
import time
from daemonize import Daemonize
import logging
import glob
import os.path
import math
import pprint
from sseclient import SSEClient
from logging.handlers import RotatingFileHandler

from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

logger = logging.getLogger(__name__)

ha_url = ""
ha_key = ""
dash_host = ""
dash_dir = ""
widgets = {}
monitored_files = {}

def roundup(x):
    return int(math.ceil(x / 10.0)) * 10
  
def call_ha(widget_id, values):
  global logger
  url = "http://" + dash_host + "/widgets/" + widget_id
  logger.debug(url)
  logger.debug(str(values))
  try:
    response = requests.post(url, verify = False, json = values)
  except requests.exceptions.RequestException as e:
    logger.warn("Unexpected error calling Dashing: %s", e)

def process_message(msg):
  global logger
  global widgets
  
  if msg.data == "ping":
    return

  # Check to see if dashboards have changed
  readDashboards()

  try:
    data = json.loads(msg.data)
    logger.debug("Event type:{}:".format(data['event_type']))
    if data['event_type'] == "state_changed":
      try:
        entity_id = data['data']['new_state']['entity_id']
        logger.debug("Entity ID:{}:".format(entity_id))
        parts = entity_id.split(".")
        type = parts[0]
        widget_id = parts[1]
        
        # Check to see if we have the widget registered and also where to send the notification
        
        if type in widgets and widget_id in widgets[type]:
          for widget in widgets[type][widget_id]:
            send_type = widgets[type][widget_id][widget]
            state = data['data']['new_state']
            # Send it
            dashboard_update(widget, send_type, state)
      except: TypeError

  except ValueError as e:
    logger.warn("Malformed JSON: %s", e)
    logger.warn("%s", msg)
  except:
    logger.warn("Unexpected error:")
    logger.warn('-'*60)
    logger.warn(traceback.format_exc())
    logger.warn('-'*60)

def dashboard_update(widget_id, type, state):
  
  try:
    if type == "switch":
      values = {"state": state['state']}
      logger.info("switch." + widget_id + " -> " + state['state'])
      call_ha(widget_id, values)
    elif type == "group":
      values = {"value": state['state']}
      logger.info("input_select." + widget_id + " -> " + state['state'])
      call_ha(widget_id, values)
    elif type == "device_tracker":
      values = {"state": state['state']}
      logger.info("devicetracker." + widget_id + " -> " + state['state'])
      call_ha(widget_id, values)
    elif type == "input_select":
      values = {"value": state['state']}
      logger.info("input_select." + widget_id + " -> " + state['state'])
      call_ha(widget_id, values)
    elif type == "input_boolean":
      values = {"state": state['state']}
      logger.info("input_boolean." + widget_id + " -> " + state['state'])
      call_ha(widget_id, values)
    elif type == "binary_sensor":
      values = {"state": state['state']}
      logger.info("binary_sensor." + widget_id + " -> " + state['state'])
      call_ha(widget_id, values)
    elif type == "sensor":
      values = {"value": state['state']}
      logger.info("sensor." + widget_id + " -> " + state['state'])
      call_ha(widget_id, values)
    elif type == "light":
      astate = state['state']
      try:
        brightness = roundup(int(state['attributes']['brightness'])/2.55)
      except KeyError:
        brightness = 30
        astate = 'off'
      values = {"state": astate, "level": brightness}
      logger.info("switch." + widget_id + " -> state = " + astate + ", brightness = " + str(brightness))
      call_ha(widget_id, values)
    elif type == "garage_door":
      values = {"state": state['state']}
      logger.info("garage_door." + widget_id + " -> " + state['state'])
      call_ha(widget_id, values)
    elif type == "lock":
      values = {"state": state['state']}
      logger.info("lock." + widget_id + " -> " + state['state'])
      call_ha(widget_id, values)
    elif type == "script":
      values = {"mode": state['state']}
      logger.info("script." + widget_id + " -> " + state['state'])
      call_ha(widget_id, values)
  except:
    logger.warn("Unexpected error:")
    logger.warn('-'*60)
    logger.warn(traceback.format_exc())
    logger.warn('-'*60)

def translate_view(view):
  views = {
        "Hadevicetracker": "device_tracker",
        "Hagarage": "garage_door",
        "Halock": "lock",
        "Hainputboolean": "input_boolean",
        "Halux": "sensor",
        "Hascene": "scene",
        "Haswitch": "switch",
        "Hagroup": "group",
        "Hadimmer": "light",
        "Hahumidity": "sensor",
        "Hainputselect": "input_select",
        "Hamotion": "binary_sensor",
        "Hamode": "script",
        "Hatemp": "sensor",
        "Hasensor": "sensor"
      }
  if view in views:
    return views[view]
  else:
    return "none"
  
    
def readDash(file):
  global widgets

  logger.info("Reading dashboard: %s", file)

  div = re.compile('<div.+>')
  id = re.compile('data-id\s*?=\s*?"(.+?)"')
  input = re.compile('data-input\s*?=\s*?"(.+?)"')
  view = re.compile('data-view\s*?=\s*?"(.+?)"')
  
  with open(file) as f:
    for line in f:
      
      data_id = ""
      data_input = ""
      data_view = ""
      
      # Find a <div>
      m1 = div.search(line)
      if m1:
        # Check for data-id
        m2 = id.search(m1.group())
        if m2:
          # grab data-id
          data_id = m2.group(1)
          # grab data-view
          m3 = view.search(m1.group())
          if m3:
            data_view = (translate_view(m3.group(1)))
          # grab data-input
          m4 = input.search(m1.group())
          if m4:
            data_input = m4.group(1)

      if data_id: 
        if not data_view in widgets:
          widgets[data_view] = {}
        if (data_input):
          # If we have a data-input this is a special case of a script that shows status based on an input_select
          # We need to register it as interested in events from that input select
          if not "input_select" in widgets:
            widgets["input_select"] = {}
          if not data_input in widgets["input_select"]:
            widgets["input_select"][data_input] = {}
          widgets["input_select"][data_input][data_id] = data_view
        else:
          if not data_id in widgets[data_view]:
            widgets[data_view][data_id] = {}
          widgets[data_view][data_id][data_id] = data_view
      
def readDashboards():
  global monitored_files
  global dash_dir
  
  found_files = glob.glob(os.path.join(dash_dir, '*.erb'))
  for file in found_files:
    if file == "{0}/layout.erb".format(dash_dir):
      continue
    modified = os.path.getmtime(file)
    if file in monitored_files:
      if monitored_files[file] < modified:
        readDash(file)
        monitored_files[file] = modified
    else:
      readDash(file)
      monitored_files[file] = modified

def run():

  global ha_url
  global ha_key
  global dash_host
  global logger
  
  while True:
    try:
      headers = {'Content-Type' : 'application/json'}
      if ha_key != "":
        headers['x-ha-access'] = ha_key
      messages = SSEClient(ha_url + "/api/stream", verify = False, headers = headers, retry = 3000)
      for msg in messages:
        process_message(msg)
    except requests.exceptions.ConnectionError:
      logger.warning("Unable to connect to Home Assistant, retrying in 5 seconds")
    except:
      logger.fatal("Unexpected error:")
      logger.fatal('-'*60)
      logger.fatal(traceback.format_exc())
      logger.fatal('-'*60)
    time.sleep(5)

def main():

  global ha_url
  global ha_key
  global dash_host
  global dash_dir
  global logger
  
  # Get command line args
  
  parser = argparse.ArgumentParser()

  parser.add_argument("config", help="full path to config file", type=str)
  parser.add_argument("-d", "--daemon", help="run as a background process", action="store_true")
  parser.add_argument("-p", "--pidfile", help="full path to PID File", default = "/tmp/hapush.pid")
  parser.add_argument("-D", "--debug", help="debug level", default = "INFO", choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"])
  args = parser.parse_args()
  config_file = args.config
  
  isdaemon = args.daemon

  # Read Config File

  config = ConfigObj(config_file, file_error=True)

  ha_url = config['ha_url']
  if 'ha_key' in config:
    ha_key = config['ha_key']
  dash_host = config['dash_host']
  dash_dir = config['dash_dir']
  logfile = config['logfile']
  
  # Setup Logging
  
  logger = logging.getLogger(__name__)
  numeric_level = getattr(logging, args.debug, None)
  logger.setLevel(numeric_level)
  logger.propagate = False
  formatter = logging.Formatter('%(asctime)s %(levelname)s %(message)s')

  # Send to file if we are daemonizing, else send to console
  
  if isdaemon:
    fh = RotatingFileHandler(logfile, maxBytes=1000000, backupCount=3)
    fh.setLevel(numeric_level)
    fh.setFormatter(formatter)
    logger.addHandler(fh)
  else:
    ch = logging.StreamHandler()
    ch.setLevel(numeric_level)
    ch.setFormatter(formatter)
    logger.addHandler(ch)

  # Read dashboards
  
  readDashboards()
  
  # Start main loop

  if isdaemon:
    keep_fds = [fh.stream.fileno()]
    pid = args.pidfile
    daemon = Daemonize(app="hapush", pid=pid, action=run, keep_fds=keep_fds) 
    daemon.start()
    while True:
      time.sleep(1)
  else:
    run()
    

  
if __name__ == "__main__":
    main()
