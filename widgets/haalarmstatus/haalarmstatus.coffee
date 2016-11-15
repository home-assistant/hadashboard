class Dashing.Haalarmstatus extends Dashing.Widget
  constructor: ->
    super
    @queryState()

  @accessor 'value',
    get: -> @_value ? 'UNKNOWN'
    set: (key, value) ->
      if value == "disarmed"
        @_value = "DISARMED"
      else if value == "pending"
        @_value = "PENDING"
      else if value == "armed_home"
        @_value = "ARMED (HOME)"
      else if value == "armed_away"
        @_value = "ARMED (AWAY)"
      else if value == "triggered"
        @_value = "TRIGGERED"
      else
        @_value = value

  queryState: ->
    $.get '/homeassistant/alarm_control_panel_status',
      widgetId: @get('id'),
      (data) =>
        json = JSON.parse data
        @set 'value', json.value

  ready: ->
    if @get('bgcolor')
      $(@node).css("background-color", @get('bgcolor'))

  onData: (data) ->
