class Dashing.Haalarmstatus extends Dashing.Widget
  constructor: ->
    super
    @queryState()

  @accessor 'value',
    get: -> @_value ? 'UNKNOWN'
    set: (key, value) -> @_value = value

  queryState: ->
    $.get '/homeassistant/alarm_control_panel_status',
      widgetId: @get('id'),
      (data) =>
        json = JSON.parse data
        @set 'value', json.value

  ready: ->
    if @get('bgcolor')
      $(@node).css("background-color", @get('bgcolor'))
    else
      $(@node).css("background-color", "#444")

  onData: (data) ->

