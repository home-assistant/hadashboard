# Send a heartbeat message to keep the event stream open
SCHEDULER.every '15s', :first_in => 0 do |job|
  event = ":heartbeat #{Time.now.to_i}\n\n"
  Sinatra::Application.settings.connections.each { |out| out << event }
end
