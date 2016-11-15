class Dashing.Habinary extends Dashing.Widget
  constructor: ->
    super
    @queryState()

  @accessor 'state',
    get: -> @_state ? "off"
    set: (key, value) -> @_state = value

  @accessor 'icon',
    get: -> if @['icon'] then @['icon'] else
      if @get('state') == 'on' then @get('iconon') else @get('iconoff')
    set: Batman.Property.defaultAccessor.set

  @accessor 'iconon',
    get: -> @['iconon'] ? 'bullseye'
    set: Batman.Property.defaultAccessor.set

  @accessor 'iconoff',
    get: -> @['iconoff'] ? 'minus'
    set: Batman.Property.defaultAccessor.set

  @accessor 'icon-style', ->
    if @get('state') == 'on' then 'icon-active' else 'icon-inactive'

  queryState: ->
    $.get '/homeassistant/binarysensor',
      widgetId: @get('id')
      (data) =>
        json = JSON.parse data
        @set 'state', json.state

  ready: ->
    if @get('bgcolor')
      $(@node).css("background-color", @get('bgcolor'))
