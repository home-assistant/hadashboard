class Dashing.Hadevicetracker extends Dashing.ClickableWidget
  constructor: ->
    super
    @queryState()

  @accessor 'state',
    get: -> @_state ? 'off'
    set: (key, value) -> @_state = value

  format_state: ->


  @accessor 'icon',
    get: -> if @['icon'] then @['icon'] else
      if @get('state') == 'HOME' then @get('iconon') else @get('iconoff')
    set: Batman.Property.defaultAccessor.set

  @accessor 'iconon',
    get: -> @['iconon'] ? 'user'
    set: Batman.Property.defaultAccessor.set

  @accessor 'iconoff',
    get: -> @['iconoff'] ? 'times'
    set: Batman.Property.defaultAccessor.set

  @accessor 'icon-style', ->
    if @get('state') == 'HOME' then 'icon-present' else 'icon-absent'

  toggleState: ->
    newState = if @get('state') == 'HOME' then 'AWAY' else 'HOME'
    @set 'state', newState
    return newState

  queryState: ->
    $.get '/homeassistant/devicetracker',
      widgetId: @get('id'),
      (data) =>
        json = JSON.parse data
        @set 'state', json.state

  postState: ->
    newState = @toggleState()
    $.post '/homeassistant/devicetracker',
      widgetId: @get('id'),
      command: newState,
      (data) =>
        json = JSON.parse data
        if json.error != 0
          @toggleState()

  ready: ->
    if @get('bgcolor')
      $(@node).css("background-color", @get('bgcolor'))

  onClick: (event) ->
    @postState()
