require 'json'
require 'net/http'

$selectedDimmer = {}

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

get '/homeassistant/script' do
	response = ha_api("states/input_select." + params["input"], "get")
	return JSON.generate({"mode" => response["state"]})
end

post '/homeassistant/script' do
	entity_id = "script." + params["widgetId"]
	ha_api("services/script/turn_on", "post", {"entity_id" => entity_id})
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
	return JSON.generate({"state" => response["state"]})
end

post '/homeassistant/devicetracker' do
	entity_id = params["widgetId"]
	ha_api("services/device_tracker/see", "post", {"dev_id" => entity_id, "location_name" => params["command"]})
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

get '/homeassistant/temperature' do
	response = ha_api("states/sensor." + params["widgetId"], "get")
	return JSON.generate({"value" => response["state"]})
end

get '/homeassistant/lux' do
	response = ha_api("states/sensor." + params["widgetId"], "get")
	return JSON.generate({"value" => response["state"]})
end

get '/homeassistant/motion' do
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
	response = ha_api("states/sensor.weather_temperature", "get")
	temp = response["state"]

	response = ha_api("states/sensor.weather_humidity", "get")
	humidity = response["state"]

	response = ha_api("states/sensor.weather_precip_probability", "get")
	precip = response["state"]

	response = ha_api("states/sensor.weather_precip_intensity", "get")
	precipintensity = response["state"]

	response = ha_api("states/sensor.weather_wind_speed", "get")
	windspeed = response["state"]

	response = ha_api("states/sensor.weather_pressure", "get")
	pressure = response["state"]
	
	response = ha_api("states/sensor.weather_wind_bearing", "get")
	windbearing = response["state"]

	
	response = ha_api("states/sensor.weather_apparent_temperature", "get")
	tempchill = response["state"]
	chill = Integer(Float(temp) - Float(tempchill) + 0.5)
	
	response = ha_api("states/sensor.weather_icon", "get")
	icon = response["state"].gsub(/-/, '_')
 
	#Emit the event
	send_event('weather', {
		temp: temp,
		humidity: humidity,
		icon: icon,
		tempchill: chill,
		precipintensity: precipintensity,
		precip: precip,
		windspeed: windspeed,
		windbearing: windbearing,
		pressure: pressure
	})
end
