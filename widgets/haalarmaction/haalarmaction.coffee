class Dashing.Haalarmaction extends Dashing.ClickableWidget
  constructor: ->
    super

  state = 'off'
    
  @accessor 'icon',
    get: -> @['icon'] ? 'tag'
    set: Batman.Property.defaultAccessor.set

  @accessor 'icon-style',
    get: -> if state == 'on' then 'icon-active' else 'icon-inactive'
    set: Batman.Property.defaultAccessor.set

  @accessor 'title-style',
    get: -> if state == 'on' then 'title-active' else 'title-inactive'
    set: Batman.Property.defaultAccessor.set

  ready: ->
    if @get('bgcolor')
      $(@node).css("background-color", @get('bgcolor'))
    else
      $(@node).css("background-color", "#444")

  turnOff: =>
    state = 'off'
    @set 'icon-style', 'icon-inactive'
    @set 'title-style', 'title-inactive'
  
  postScene: ->
    $.post '/homeassistant/alarm_control_panel_action',
      action: @get('action'),
      (data) =>
        json = JSON.parse data
        if json.error != 0
          @toggleState()

  onClick: (event) ->
    @postScene()
    state = 'on'
    @set 'icon-style', 'icon-active'
    @set 'title-style', 'title-active'
    @_timeout = setTimeout(@turnOff, @['ontime'] ? 1000)

