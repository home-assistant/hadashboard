# Description

HADashboard is a dashboard for [Home Assistant](https://home-assistant.io/) that is intended to be wall mounted, and is optimized for distance viewing.

![UI](images/dash.png)

HADashboard was originally created by the excellent work of [FlorianZ](https://github.com/FlorianZ/hadashboard) for use with the SmartThings Home Automation system, with notable contributions from the [SmartThings Community](https://community.smartthings.com/t/home-automation-dashboard/4926). I would also like to acknowledge contributions made by [zipriddy](https://github.com/zpriddy/SmartThings_PyDash). This is my port of hadashboard to Home Assistant.

# Architecture

The Dashboard is at its heart a [Dashing](http://dashing.io/) Dashboard. Dashing is a ruby on rails based framework that enables easy creation of extensible dashboards. The Ruby environment runs a webserver that serves the dashboard, and also provides a backend to call into Home Assistant using it's RESTFull API. In addition, the Dashboard itself provides an API for push updates, and there is a python component called `hapush` that consumes events from Home Assistant and pushes them back to the dashboard in real time so it is continuously updated without the need for reloading.

# Installation

## Clone the Repository
Clone the **hadashboard** repository to the current local directory on your machine.

``` bash
$ git clone https://github.com/home-assistant/hadashboard.git
```

Change your working directory to the repository root. Moving forward, we will be working from this directory.

``` bash
$ cd hadashboard
```

## 2. Install Dashing and prereqs

Essentially, you want to make sure that you have Ruby installed on your local machine. Then, install the Dashing gem:

``` bash
$ gem install dashing
```

From your repository root, make sure that all dependencies are available.

Note: on some systems you may also need to install bundler:

```bash
$ gem install bundler
```

When installed run it:

``` bash
$ bundle
```

Bundle will now install all the ruby prereqs for running dashing.

Note: Prereqs will vary across different machines. So far users have reported requirements for some additional installs to allow the bundle to complete succesfully:

- ruby-dev - `sudo apt-get install ruby-dev`
- Postgress - `sudo apt-get install postgresql-9.4 postgresql-server-dev-9.4 libpq-dev sqlite libsqlite3-dev`
- node-js - `sudo apt-get install nodejs`
- execjs gem - `gem install execjs`

You will need to research what works on your particular architecture and also bear in mind that version numbers may change over time.

Note: This is currently running on ruby version 2.1.5, and if you try to run with a different version you may get an error like:

``
Your Ruby version is 2.3.0, but your Gemfile specified 2.1.5
``

To fix this, you need to change the version of ruby specified in `Gemfile`, the directive is:
```
ruby "2.1.5"
```

In the example above you would need to change it to `2.3.0`. Note that this has not been tested by me and your mileage may vary if you use an arbitary version of ruby, however, the version above (`2.3.0`) has been reported to run correctly, and in most cases it should be fine.

Next, in the `./lib` directory, copy the ha_conf.rb.example file to ha_conf.rb and edit its settings to reflect your installation, pointing to the machine Home Assistant is running on and adding your api_key.

```ruby
$ha_url = "http://192.168.1.10:8123"
$ha_apikey = "your key"
```

- `$ha_url` is a reference to your home assistant installation and must include the correct port number and scheme (`http://` or `https://` as appropriate)
- `$ha_apikey` should be set to your key if you have one, otherwise it can remain blank.

The file also contains example newsfeeds for the News widget:

```ruby
$news_feeds = {
  "Traffic" => "http://api.sr.se/api/rss/traffic/2863",
  "News" => "http://feeds.bbci.co.uk/news/rss.xml",
}
```

You can leave these alone for now or if you prefer customize them as described in the New widget section below.

When you are done, you can start a local webserver like this:

``` bash
$ dashing start
```

Point your browser to **http://localhost:3030** to access the hadashboard on your local machine.and you should see the supplied default dashboard.

# Configuring The Dashboard
Hadashboard is a Dashing app, so make sure to read all the instructions on http://dashing.io to learn how to add widgets to your dashboard, as well as how to create new widgets. 

Make a copy of dashboards/example.erb and call it 'main.erb', then edit this file to reference the items you want to display and control and to get the layout that you want. Leave the original example.erb intact and unchanged so that you don't run into problems when trying to update using the git commands mentioned later in "Updating the Dashboard".

The basic anatomy of a widget is this:
``` html
 	<li data-row="" data-col="1" data-sizex="1" data-sizey="1">
      <div data-id="office" data-view="Hadimmer" data-title="Office Lamp"></div>
    </li>
```
- **data-row**, **data-col**: The position of the widget in the grid.
- **data-sizex**, **data-sizey**: The size of the widget in terms of grid tile.
- **data-id**: The homeassitant entity id without the entity type (e.g. `light.office` becomes `office`).
- **data-view**: The type of widget to be used (Haswitch, Hadimmer, Hatemp etc.)
- **data-icon**: The icon displayed on the tile. See http://fontawesome.io for an icon cheatsheet.
- **data-title**: The title to be displayed on the tile. 
- ***data-bgcolor*** (optional) - the background color of the widget.

Note that although it is legal in XML terms to split the inner `<div>` like this:

``` html
 	<li data-row="" data-col="1" data-sizex="1" data-sizey="1">
      <div data-id="office" 
            data-view="Hadimmer" 
            data-title="Office Lamp">
      </div>
    </li>
```

This may break `hapush`'s parsing of the file, so keep to the line format first presented.

Please, refer to the Dashing website for instructions on how to change the grid and tile size, as well as more general instructions about widgets, their properties, and how to create new widgets.

# Supported Widgets

At this time I have provided support for the following Home Assistant entity types.


## switch
Widget type ***Haswitch***
## lock
Widget type ***Halock***
## devicetracker
Widget type ***Hadevicetracker***
## light
Widget type  ***Hadimmer***
## garage
Widget type ***Hagarage***
## input_boolean
Widget type ***Hainputboolean***
## scene
Widget type ***Hascene***  

**data-ontime** (optional): The amount of time the scene icon lights up when pressed, in milliseconds, default 1000.

## script

Widget type ***Hascript*** 

**data-ontime** (optional): The amount of time the scene icon lights up when pressed, in milliseconds, default 1000.

## mode

The `Hamode` widget alows you to run a script on activation and to link it with a specified `input_select` so the button will be highlighted for certain values of that input select. The usecase for this is that I maintain an `input_select` as a flag for the state of the house to simplify other automations. I use scripts to switch between the states, and this feature provides feedback as to the current state by lighting up the appropriate mode button.

A `Hamode` widget using this feature will look like this:

```html
<li data-row="5" data-col="3" data-sizex="2" data-sizey="1">
      <div data-id="day" data-view="Hamode" data-title="Good Day" data-icon="sun-o" data-changemode="Day" data-input="house_mode"></div>
    </li>
```
**data-changemode**: The value of the `input_select` for which this script button will light up 

**data-input**: The `input_select` entity to use (minus the leading entity type)

## input_select (read only)
Widget type ***Hainputselect***

## sensor
Widget type ***Hasensor***  

Text based output of the value of a particular sensor.

The Hasensor widget supports an additional paramater  `data-unit` - this allows you to set the unit to whatever you want - Centigrade, %, lux or whatever you need for the sensor in question. For a temperature sensor you will need to explicitly include the degree symbol like this:
```html
data-unit="&deg;F"
```
If omitted, no units will be shown.

## sensor
Widget type ***Hameter***  

An alternative to the text based `Hasensor` that works for numeric values only.

The Hameter widget supports an additional paramater  `data-unit` - this allows you to set the unit to whatever you want - Centigrade, %, lux or whatever you need for the sensor in question. For a temperature sensor you will need to explicitly include the degree symbol like this:
```html
data-unit="&deg;F"
```
If omitted, no units will be shown.

## group
Widget type ***Hagroup***

The Hagroup widget uses the homeassistant/turn_on and homeassistant/turn_off API call, so certain functionality will be lost.  For example, you will not be able to use control groups of locks or dim lights.

# Alarm Control Panel

These widgets allow the user to create a working control panel that can be used to control the Manual Alarm Control Panel component (https://home-assistant.io/components/alarm_control_panel.manual). The example dashboard contains an arrangement similar to this:

![UI](images/alarm_panel.png)

Widget type ***Haalarmstatus***

The Haalarmstatus widget displays the current status of the alarm_control_panel entity. It will also display the code as it is being entered by the user.

The data-id must be the same as the alarm_control_panel entity_id in Home Assistant.

Widget type ***Haalarmdigit***

The Haalarmdigit widget is used to create the numeric keypad for entering alarm codes.

data-digit holds the numeric value you wish to enter. The special value of "-" creates a 'clear' button which will wipe the code and return the Haalarmstatus widget display back to the current alarm state.

data-alarmentity holds the data-id of the Haalarmstatus widget, so that the status widget can be correctly updated. It is mandatory for a 'clear' type digit and optional for normal numeric buttons.

Widget type ***Haalarmaction***

The Haalarmaction widget creates the arm/disarm/trigger buttons. Bear in mind that alarm triggering does not require a code, so you may not want to put this button near the other buttons in case it is pressed accidentally.

data-action must contain one of the following: arm_home/arm_away/trigger/disarm.

# weather (requires forecast.io)

Widget type ***Haweather***

In order to use the weather widget you must configure the forecast.io component, and ensure that you configure at least the following monitored conditions in your Home Assistant sensor config:

- temperature
- humidity
- precip_probability
- precip_intensity
- wind_speed
- pressure
- wind_bearing
- apparent_temperature
- icon

The `data-id` of the Haweather widget must be set to `weather` or the widget will not work.

The Hatemp widget supports an additional paramater  `data-unit` - this allows you to set the unit to whatever you want - Centigrade, Farenheight or even Kelvin if you prefer ;) You will need to explicitly include the degree symbol like this:
```html
data-unit="&deg;F"
```
If omitted, no units will be shown.## news
Widget type ***News*** (contributed by [KRiS](https://community.home-assistant.io/users/kris/activity))  

This is an RSS widget that can be used for displaying travel information, news etc. on the dashboard. The RSS feed will update every 6o minutes. To configure this, first it is necessary to add your desired feeds in `homeassistant/lib/ha_conf.rb` in the `$news_feeds` section. By default it comes with 2 sample feeds:
```ruby
$news_feeds = {
  "Traffic" => "http://api.sr.se/api/rss/traffic/2863",
  "News" => "http://feeds.bbci.co.uk/news/rss.xml",
}
```
You can add as many as you want. The important point is that the key value (e.g. "Traffic" or "News" in the example above is used to tie the feed to your widget in the dashboard file. Here is an example of the Traffic widget that displays the first feed in the list:

```html
<li data-row="3" data-col="2" data-sizex="2" data-sizey="2">
  <div data-id="Traffic" data-view="News" data-title="Traffic" data-interval="30" data-bgcolor="#643EBF">
</li>
```
The value of thee `data-id` tag must match the key value in the `$news_feeds` configuration.

- ***data-interval*** (optional) - the time in seconds that each entry in the RSS feed is displayed before the next one is shown, default is 30 seconds.


***The follwing widget types have been deprecated in favor of the more flexible `Hasensor` and `Hameter` widgets. They will be removed in a future release.***

## sensor (humidity)
Widget type ***Hahumidity***

## sensor (humidity)
Widget type ***Hahumiditymeter*** (contributed by [Shiv Chanders](https://community.home-assistant.io/users/chanders/activity))  

This is an alternative to the the text based humidity widget above, it display the humidity as an animated meter from 0 to 100%.

## sensor (luminance)
Widget type ***Halux***
## sensor (motion)
Widget type ***Hamotion***

## sensor (temperature)
Widget type ***Hatemp***  

The Hatemp widget supports an additional paramater  `data-unit` - this allows you to set the unit to whatever you want - Centigrade, Farenheight or even Kelvin if you prefer ;) You will need to explicitly include the degree symbol like this:
```html
data-unit="&deg;F"
```
If omitted, no units will be shown.

# Changes and Restarting

When you make changes to a dashboard, Dashing and `hapush` will both automatically reload and apply the changes without a need to restart.

Note: The first time you start Dashing, it can take up to a minute for the initial compilation of the pages to occur. You might get a timeout from your browser. If this occurs, be patient and reload. Subsequent reloads will be a lot quicker.

# Multiple Pages

It is possible to have multiple pages within a dashboard. To do this, you can add an arbitary number of gridster divisions (you need at least one).

```html
<div class="gridster"> <!-- Main Panel - PAGE 1 -->
  <some widgets>
</div
<div class="gridster"> <!-- More Stuff - PAGE 2 -->
  <more widgets>
</div
```

The divisions are implicitly numbered from 1 so it is a good idea to comment them. You can then add a widget to switch between pages like so:

```html
<li data-row="1" data-col="1" data-sizex="1" data-sizey="1">
    <div data-id="cpage1" data-view="ChangePage" data-icon="cogs" data-title="Upstairs" data-page="3" data-stagger="false" data-fasttransition="true" data-event-click="onClick"></div>
</li>
```
- ***data-page*** : The name of the page to switch to 

# Multiple Dashboards
You can also have multiple dashboards, by simply adding a new .erb file to the dashboards directory and navigating to the dashboards via `http://<IP address>:3030/dashboard-file-name-without-extension`

For example, if you want to deploy multiple devices, you could have one dashboard per room and still only use one hadashboard app installation.

# Installing hapush

When you have the dashboard correctly displaying and interacting with Home Assistant you are ready to install the final component - `hapush`. Without `hapush` the dashboard would not respond to events that happen outside of the hadashboard system. For instance, if someone uses the Home Assistant interface to turn on a light, or even another App or physical switch, there is no way for the Dashboard to reflect this change. This is where `hapush` comes in.

`hapush` is a python daemon that listens to Home Assistant's Event Stream and pushes changes back to the dashboard to update it in real time. You may want to create a [Virtual Environment](https://docs.python.org/3/library/venv.html) for hapush - at the time of writing there is a conflict in the Event Source versions in use between HA and hapush.

Before running `hapush` you will need to add some python prerequisites:

```bash
$ sudo pip3 install daemonize
$ sudo pip3 install sseclient
$ sudo pip3 install configobj
```

Some users are reporting errors with `InsecureRequestWarning`:
```
Traceback (most recent call last):
  File "./hapush.py", line 21, in <module>
    from requests.packages.urllib3.exceptions import InsecureRequestWarning
ImportError: cannot import name 'InsecureRequestWarning'
```
This can be fixed with:
```
$ sudo pip3 install --upgrade requests
```


When you have all the prereqs in place, edit the hapush.cfg file to reflect your environment:

```
ha_url = "http://192.168.1.10:8123"
ha_key = api_key
dash_host = "192.168.1.10:3030"
dash_dir = "/srv/hass/src/hadashboard/dashboards"
logfile = "/etc/hapush/hapush.log"
```

- `ha_url` is a reference to your home assistant installation and must include the correct port number and scheme (`http://` or `https://` as appropriate)
- `ha_key` should be set to your key if you have one, otherwise it can be removed.
- `dash_host` should be set to the IP address and port of the host you are running Dashing on (no http or https) - this should be the same machine as you are running `hapush` on.
- `dash_dir` is the path on the machine that stores your dashboards. This will be the subdirectory `dashboards` relative to the path you cloned `hadashboard` to. 
- `logfile` is the path to where you want `hapush` to keep its logs. When run from the command line this is not used - log messages come out on the terminal. When running as a daemon this is where the log information will go. In the example above I created a directory specifically for hapush to run from, although there is no reason you can't keep it in the `hapush` subdirectory of the cloned repository.


You can then run hapush from the command line as follows:

```bash
$ ./hapush.py hapush.cfg
```

If all is well, you should start to see `hapush` responding to events as they occur:

```
2016-06-19 10:05:59,693 INFO Reading dashboard: /srv/hass/src/hadashboard/dashboards/main.erb
2016-06-19 10:06:12,362 INFO switch.wendy_bedside -> state = on, brightness = 50
2016-06-19 10:06:13,334 INFO switch.andrew_bedside -> state = on, brightness = 50
2016-06-19 10:06:13,910 INFO script.night -> Night
2016-06-19 10:06:13,935 INFO script.night_quiet -> Night
2016-06-19 10:06:13,959 INFO script.day -> Night
2016-06-19 10:06:13,984 INFO script.evening -> Night
2016-06-19 10:06:14,008 INFO input_select.house_mode -> Night
2016-06-19 10:06:14,038 INFO script.morning -> Night
2016-06-19 10:06:21,624 INFO script.night -> Day
2016-06-19 10:06:21,649 INFO script.night_quiet -> Day
2016-06-19 10:06:21,674 INFO script.day -> Day
2016-06-19 10:06:21,698 INFO script.evening -> Day
2016-06-19 10:06:21,724 INFO input_select.house_mode -> Day
2016-06-19 10:06:21,748 INFO script.morning -> Day
2016-06-19 10:06:31,084 INFO switch.andrew_bedside -> state = off, brightness = 30
2016-06-19 10:06:32,501 INFO switch.wendy_bedside -> state = off, brightness = 30
2016-06-19 10:06:52,280 INFO sensor.side_multisensor_luminance_25 -> 871.0
2016-06-19 10:07:50,574 INFO sensor.side_temp_corrected -> 70.7
2016-06-19 10:07:51,478 INFO sensor.side_multisensor_relative_humidity_25 -> 52.0
```

# Starting At Reboot
To run Dashing and `hapush` at reboot, I have provided sample init scripts in the `./init` directory. These have been tested on a Raspberry PI - your mileage may vary on other systems.

# Updating The Dashboard
To update the dashboard after I have released new code, just run the following command to update your copy:

```bash
$ git pull origin
```

For some releases you may also need to rerun the bundle command:
``` bash
$ bundle
```
# Release Notes
***Version 1.6***

- Merge Haalarm widgets contributed by [Soul](https://community.home-assistant.io/users/soul/activity)
- Allow Haweather units to be specified as a parameter

***Version 1.5.1***

- Fixed an issue with Float conversions on a weather field

*Changes in behavior*

`Wind Chill` on the weather widget has been replaced by `Apparent Temperature` which is now passed straight through from the sensor value.

***Version 1.5***

- Merge Hagroup contributed by [jwl173305361](https://community.home-assistant.io/users/jwl173305361/activity)
- Add background color support for all widgets

***Version 1.4***

- Addition of Halock contributed by [jwl173305361](https://community.home-assistant.io/users/jwl173305361/activity)
- Addition of Hasensor
- Addition of Hameter

*Breaking Changes*

None, however, Hasensor is intended as a replacement for Hatemp, Hahumidity and Halux, which are now deprecared and will be removed in a future release. Similarly, Hameter is intended to replace Hahumiditymeter.

***Version 1.3.2***

- Script buttons now light up for a configurable period when activated
- In order to accommodate the above change, functionality to run scripts and track the state of an input_select has been broken out into a new widget called `Hamode`

*Breaking Changes*

- Hascript no longer has the ability to track and display the state of an input_slelect. If you were using this functionality, change the type of your widget to `Hamode`


***Version 1.3.1***

- Scene buttons now light up for a configurable period when activated

***Version 1.3***

- Merge RSS widget contributed by [KRiS](https://community.home-assistant.io/users/kris/activity)
- Merge Hahumiditymeter contributed by [Shiv Chanders](https://community.home-assistant.io/users/chanders/activity)
- Allow temperature unit to be specified in the dasboard
- Remove main.erb and replace it with example.erb
- Update README to reflect new widgets
- Update README with additional install notes
- Update README with section on updating the dashboard

*Breaking Changes*

Previously temperature units defaulted to Fahrenheit - now there is no default, you must explicitly specify it in the Hatemp widget or you will get no units at all.

***Version 1.2.1***

- Minor typos in README

***Version 1.2***

- Fix docs and excample cfg to remove scheme from `hapush` dash_host config variable

***Version 1.1*** 

- Expand instructions
- Allow no api_key
- Allow http connections

***Version 1.0***

Initial Release
