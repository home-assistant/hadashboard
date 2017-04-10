class Dashing.Hainputslider extends Dashing.ClickableWidget
  constructor: ->
    super
    @queryState()

  @accessor 'value',
    get: -> if @_value then @_value else 0
    set: (key, value) -> @_value = value

  plusValue: ->
    newValue = ((@get('value'))*1)+@get('steps')
    if newValue > @get('maximum')
      newValue = @get('maximum')
    else if newValue < @get('minimum')
      newValue = @get('minimum')
    @set 'value', newValue
    return @get('value')

  minusValue: ->
    newValue = ((@get('value'))*1)-@get('steps')
    if newValue > @get('maximum')
      newValue = @get('maximum')
    else if newValue < @get('minimum')
      newValue = @get('minimum')
    @set 'value', newValue
    return @get('value')

  queryState: ->
    $.get '/homeassistant/input_slider',
      widgetId: @get('id'),
      deviceId: @get('device')
      (data) =>
        json = JSON.parse data
        @set 'value', json.value

  ValueUp: ->
    newValue = @plusValue()
    $.post '/homeassistant/input_slider',
      widgetId: @get('id'),
      command: newValue,
      (data) =>
        json = JSON.parse data

  ValueDown: ->
    newValue = @minusValue()
    $.post '/homeassistant/input_slider',
      widgetId: @get('id'),
      command: newValue,
      (data) =>
        json = JSON.parse data

  ready: ->
    if @get('bgcolor')
      $(@node).css("background-color", @get('bgcolor'))
    else
      $(@node).css("background-color", "#444")

  onData: (data) ->

  onClick: (event) ->
    if event.target.id == "value-down"
      @ValueDown()
    else if event.target.id == "value-up"
      @ValueUp()

