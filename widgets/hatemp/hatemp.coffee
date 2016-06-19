class Dashing.Hatemp extends Dashing.Widget
  constructor: ->
    super
    @queryState()

  @accessor 'value',
    get: -> if @_value then Math.round(@_value) else 0
    set: (key, value) -> @_value = value

  queryState: ->
    $.get '/homeassistant/temperature',
      widgetId: @get('id'),
      deviceId: @get('device')
      (data) =>
        json = JSON.parse data
        @set 'value', json.value

  ready: ->

  onData: (data) ->
