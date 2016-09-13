class Dashing.Hacover extends Dashing.ClickableWidget
  constructor: ->
    super
    @queryState()

  @accessor 'state',
    get: -> @_state ? 'open'
    set: (key, value) -> @_state = value

  @accessor 'icon',
    get: -> 'car'
    set: Batman.Property.defaultAccessor.set

  @accessor 'icon-style', ->
    if @get('state') == 'open' then icon = 'icon-open'
    if @get('state') == 'closed' then icon = 'icon-closed'
    if @get('state') == 'opening' then icon = 'icon-opening'
    if @get('state') == 'closing' then icon = 'icon-closing'
    return icon

  toggleState: ->
    newState = if @get('state') == 'open' then 'closed' else 'open'
    @set 'state', newState
    return newState

  queryState: ->
    $.get '/homeassistant/cover',
      widgetId: @get('id'),
      (data) =>
        json = JSON.parse data
        @set 'state', json.state

  postState: ->
    newState = @toggleState()
    $.post '/homeassistant/cover',
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

  onData: (data) ->

  onClick: (event) ->
    @postState()

