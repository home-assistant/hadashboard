class Dashing.Hainputselect extends Dashing.Widget
  constructor: ->
    super
    @queryState()

  @accessor 'value',
    get: -> @_value ? "Unknown"
    set: (key, value) -> @_value = value

  queryState: ->
    $.get '/homeassistant/inputselect',
      widgetId: @get('id'),
      (data) =>
        json = JSON.parse data
        @set 'value', json.value

  ready: ->

  onData: (data) ->
