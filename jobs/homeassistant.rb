require 'json'
require 'net/http'

$selectedDimmer = {}
$alarm_control_panel_code = ""

$ha_api = $ha_url + "/api/"

def ha_api(path, method, parameters={})
	uri = URI.parse($ha_api + path)
	http = Net::HTTP.new(uri.host, uri.port)
  if uri.scheme == "https"
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
	if method == "get"
		request = Net::HTTP::Get.new(uri.request_uri)
	else
		request = Net::HTTP::Post.new(uri.request_uri)
		request.body = parameters.to_json
	end
	request.initialize_http_header({"x-ha-access" => $ha_apikey, 'Content-Type' =>'application/json'})
	response = http.request(request)
	return JSON.parse(response.body)
end

def respondWithStatus(status)
    response = JSON.generate({"error"=> status})
    return response
end

def respondWithSuccess()
	respondWithStatus(0)
end

# Dispatch requests to the Home Assistant RESTFull API

get '/homeassistant/switch' do
	response = ha_api("states/switch." + params["widgetId"], "get")
	return JSON.generate({"state" => response["state"]})
end

post '/homeassistant/switch' do
	entity_id = "switch." + params["widgetId"]
	ha_api("services/switch/turn_" + params["command"], "post", {"entity_id" => entity_id})
	return respondWithSuccess()
end

get '/homeassistant/group' do
        response = ha_api("states/group." + params["widgetId"], "get")
        return JSON.generate({"state" => response["state"]})
end

post '/homeassistant/group' do
        entity_id = "group." + params["widgetId"]
        ha_api("services/homeassistant/turn_" + params["command"], "post", {"entity_id" => entity_id})
        return respondWithSuccess()
end

get '/homeassistant/garage' do
	response = ha_api("states/garage_door." + params["widgetId"], "get")
	return JSON.generate({"state" => response["state"]})
end

post '/homeassistant/garage' do
	entity_id = "garage_door." + params["widgetId"]
	command = "close"
	if params["command"] == "open"
		command = "open"
	else
		command = "close"
	end
	ha_api("services/garage_door/" + command, "post", {"entity_id" => entity_id})
	return respondWithSuccess()
end

get '/homeassistant/cover' do
	response = ha_api("states/cover." + params["widgetId"], "get")
	return JSON.generate({"state" => response["state"]})
end

post '/homeassistant/cover' do
	entity_id = "cover." + params["widgetId"]
	command = "close_cover"
	if params["command"] == "open"
		command = "open_cover"
	else
		command = "close_cover"
	end
	ha_api("services/cover/" + command, "post", {"entity_id" => entity_id})
	return respondWithSuccess()
end


get '/homeassistant/lock' do
	response = ha_api("states/lock." + params["widgetId"], "get")
	return JSON.generate({"state" => response["state"]})
end

post '/homeassistant/lock' do
	entity_id = "lock." + params["widgetId"]
	command = "lock"
	if params["command"] == "unlock"
		command = "unlock"
	else
		command = "lock"
	end
	ha_api("services/lock/" + command, "post", {"entity_id" => entity_id})
	return respondWithSuccess()
end

get '/homeassistant/alarm_control_panel_status' do
    response = ha_api("states/alarm_control_panel." + params["widgetId"], "get")
    return JSON.generate({"value" => response["state"]})
end

post '/homeassistant/alarm_control_panel_digit' do
    digit = params["digit"]
    alarm_entity = params["alarmEntity"]

    if digit == "-"
      # the 'clear' button has been pressed
      # so blank the stored code and retrieve current status for display
      $alarm_control_panel_code = ""
      response = ha_api("states/alarm_control_panel." + alarm_entity, "get")
      status_widget_value = response["state"]
    else
      # number has been pressed so add to code
      $alarm_control_panel_code = $alarm_control_panel_code + digit
      status_widget_value = $alarm_control_panel_code
    end

    # Send value back to the alarm status widget
    send_event(alarm_entity, {
      value: status_widget_value
    })

    return respondWithSuccess()
end

post '/homeassistant/alarm_control_panel_action' do
    # action will be one of
    #   disarm
    #   arm_home
    #   arm_away
    #   trigger
    if $alarm_control_panel_code == ""
        ha_api("services/alarm_control_panel/alarm_" + params["action"], "post")
    else
        ha_api("services/alarm_control_panel/alarm_" + params["action"], "post", {"code" => $alarm_control_panel_code})
    end
    # now blank the code
    $alarm_control_panel_code = ""
    return respondWithSuccess()
end

get '/homeassistant/script' do
	response = ha_api("states/input_select." + params["input"], "get")
	return JSON.generate({"mode" => response["state"]})
end

post '/homeassistant/script' do
	entity_id = "script." + params["widgetId"]
	ha_api("services/script/turn_on", "post", {"entity_id" => entity_id})
	return respondWithSuccess()
end

post '/homeassistant/service' do
	ha_api("services/" + params["service"], "post", params["payload"])
	return respondWithSuccess()
end

post '/homeassistant/scene' do
	entity_id = "scene." + params["widgetId"]
	ha_api("services/scene/turn_on", "post", {"entity_id" => entity_id})
	return respondWithSuccess()
end

get '/homeassistant/scene' do
	response = ha_api("states/scene." + params["widgetId"], "get")
	return JSON.generate({"mode" => response["state"]})
end

get '/homeassistant/mediaplayer' do
    response = ha_api("states/media_player." + params["widgetId"], "get")
    return JSON.generate(response)
end

post '/homeassistant/mediaplayerMute' do
    entity_id = "media_player." + params["widgetId"]
    ha_api("services/media_player/volume_mute", "post", {"entity_id" => entity_id,
        "is_volume_muted" => params['command'] })
    return respondWithSuccess()
end

post '/homeassistant/mediaplayerVolumeUp' do
    entity_id = "media_player." + params["widgetId"]
    ha_api("services/media_player/volume_up", "post", {"entity_id" => entity_id})
    return respondWithSuccess()
end

post '/homeassistant/mediaplayerVolumeDown' do
    entity_id = "media_player." + params["widgetId"]
    ha_api("services/media_player/volume_down", "post", {"entity_id" => entity_id})
    return respondWithSuccess()
end

post '/homeassistant/mediaplayerVolumeSet' do
    entity_id = "media_player." + params["widgetId"]
    ha_api("services/media_player/volume_set", "post", {"entity_id" => entity_id,
        "volume_level" => Float(params["command"])})
    return respondWithSuccess()
end

post '/homeassistant/mediaplayerPlayPause' do
    entity_id = "media_player." + params["widgetId"]
    ha_api("services/media_player/media_play_pause", "post", {"entity_id" => entity_id})
    return respondWithSuccess()
end

post '/homeassistant/mediaplayerNext' do
    entity_id = "media_player." + params["widgetId"]
    ha_api("services/media_player/media_next_track", "post", {"entity_id" => entity_id})
    return respondWithSuccess()
end

post '/homeassistant/mediaplayerPrev' do
    entity_id = "media_player." + params["widgetId"]
    ha_api("services/media_player/media_previous_track", "post", {"entity_id" => entity_id})
    return respondWithSuccess()
end

get '/homeassistant/dimmer' do
	response = ha_api("states/light." + params["widgetId"], "get")
	if response["brightness"] == nil
		level = 30
	else
		level = Integer(response["brightness"]).round(-1)
	end
	return JSON.generate({"state" => response["state"], "level" => level})
end

post '/homeassistant/dimmer' do
	entity_id = "light." + params["widgetId"]
	ha_api("services/light/turn_" + params["command"], "post", {"entity_id" => entity_id})
	return respondWithSuccess()
end

post '/homeassistant/dimmerLevel' do
	entity_id = "light." + params["widgetId"]
	ha_api("services/light/turn_on", "post", {"entity_id" => entity_id, "brightness" => Integer(params["command"]) * 2.55})
	return respondWithSuccess()
end

post '/homeassistant/selectdimmer' do
	$selectedDimmer[request.ip] = params["widgetId"]
	return respondWithSuccess()
end

post '/homeassistant/setdimmer' do
	entity_id = "light." + $selectedDimmer[request.ip]
	if params["command"] == "off"
		ha_api("services/light/turn_off", "post", {"entity_id" => entity_id})
	else
		ha_api("services/light/turn_on", "post", {"entity_id" => entity_id, "brightness" => Integer(params["command"]) * 2.55})
	end
end

get '/homeassistant/devicetracker' do
	response = ha_api("states/device_tracker." + params["widgetId"], "get")
	if response["state"] == "not_home"
		state = "away"
	else
		state = response["state"]
	end

	return JSON.generate({"state" => state.upcase})
end

post '/homeassistant/devicetracker' do
	entity_id = params["widgetId"]
	state = params["command"].downcase
	if state == "away"
		state = "not_home"
	end
	ha_api("services/device_tracker/see", "post", {"dev_id" => entity_id, "location_name" => state})
	return respondWithSuccess()
end

get '/homeassistant/inputselect' do
	response = ha_api("states/input_select." + params["widgetId"], "get")
	return JSON.generate({"value" => response["state"]})
end

get '/homeassistant/inputboolean' do
	response = ha_api("states/input_boolean." + params["widgetId"], "get")
	return JSON.generate({"state" => response["state"]})
end

post '/homeassistant/inputboolean' do
	entity_id = "input_boolean." + params["widgetId"]
	ha_api("services/input_boolean/turn_" + params["command"], "post", {"entity_id" => entity_id})
	return respondWithSuccess()
end

get '/homeassistant/sensor' do
	response = ha_api("states/sensor." + params["widgetId"], "get")
	return JSON.generate({"value" => response["state"]})
end

get '/homeassistant/temperature' do
	response = ha_api("states/sensor." + params["widgetId"], "get")
	return JSON.generate({"value" => response["state"]})
end

get '/homeassistant/lux' do
	response = ha_api("states/sensor." + params["widgetId"], "get")
	return JSON.generate({"value" => response["state"]})
end

get '/homeassistant/binarysensor' do
	response = ha_api("states/binary_sensor." + params["widgetId"], "get")
	return JSON.generate({"state" => response["state"]})
end

get '/homeassistant/humidity' do
	response = ha_api("states/sensor." + params["widgetId"], "get")
	return JSON.generate({"value" => response["state"]})
end


#Update the weather ever so often
SCHEDULER.every '15m', :first_in => 0 do |job|
	#Current weather
	response = ha_api("states/sensor.dark_sky_temperature", "get")
	temp = response["state"]

	response = ha_api("states/sensor.dark_sky_humidity", "get")
	humidity = response["state"]

	response = ha_api("states/sensor.dark_sky_precip_probability", "get")
	precip = response["state"]

	response = ha_api("states/sensor.dark_sky_precip_intensity", "get")
	precipintensity = response["state"]

	response = ha_api("states/sensor.dark_sky_wind_speed", "get")
	windspeed = response["state"]

	response = ha_api("states/sensor.dark_sky_pressure", "get")
	pressure = response["state"]

	response = ha_api("states/sensor.dark_sky_wind_bearing", "get")
	windbearing = response["state"]


	response = ha_api("states/sensor.dark_sky_apparent_temperature", "get")
	tempchill = response["state"]

	response = ha_api("states/sensor.dark_sky_icon", "get")
	icon = response["state"].gsub(/-/, '_')

	#Emit the event
	send_event('weather', {
		temp: temp,
		humidity: humidity,
		icon: icon,
		tempchill: tempchill,
		precipintensity: precipintensity,
		precip: precip,
		windspeed: windspeed,
		windbearing: windbearing,
		pressure: pressure
	})
end
