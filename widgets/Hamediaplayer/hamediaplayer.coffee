class Dashing.Hamediaplayer extends Dashing.ClickableWidget
  constructor: ->
    super
    @queryState()

  @accessor 'state',
    get: -> @_state ? 'off'
    set: (key, value) -> @_state = value

  @accessor 'icon',
    get: -> if @['icon'] then @['icon'] else
      if @get('state') == 'on' then @get('iconon') else @get('iconoff')
    set: Batman.Property.defaultAccessor.set

  @accessor 'iconon',
    get: -> @['iconon'] ? 'circle'
    set: Batman.Property.defaultAccessor.set

  @accessor 'iconoff',
    get: -> @['iconoff'] ? 'circle-thin'
    set: Batman.Property.defaultAccessor.set

  @accessor 'icon-style', ->
    if @get('state') == 'on' then 'media_player-icon-on' else 'media_player-icon-off'

  toggleState: ->
    newState = if @get('state') == 'on' then 'off' else 'on'
    @set 'state', newState
    return newState

  queryState: ->
    $.get '/homeassistant/media_player',
      widgetId: @get('id'),
      (data) =>
        json = JSON.parse data
        @set 'state', json.state

  postState: ->
    newState = @toggleState()
    $.post '/homeassistant/media_player',
      widgetId: @get('id'),
      command: newState,
      (data) =>
        json = JSON.parse data
        if json.error != 0
          @toggleState()

  ready: ->
    if @get('bgcolor')
      $(@node).css("background-color", @get('bgcolor'))
    else
      $(@node).css("background-color", "#444")

  onClick: (event) ->
    @postState()
