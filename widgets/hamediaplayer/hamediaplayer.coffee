class Dashing.Hamediaplayer extends Dashing.ClickableWidget
  constructor: ->
    super
    @queryState()

  @accessor 'state',
    get: -> @_state ? 'off'
    set: (key, value) -> @_state = value

  @accessor 'level',
    get: -> @_level ? '50'
    set: (key, value) -> @_level = value

  @accessor 'icon',
    get: -> if @['icon'] then @['icon'] else
      if @get('state') == 'playing' 
        return @get('iconplay')
      else if @get('state') == 'paused' 
        return @get('iconpause')
      else 
        return @get('iconstop')
    set: Batman.Property.defaultAccessor.set

  @accessor 'iconplay',
    get: -> @['iconplay'] ? 'play'
    set: Batman.Property.defaultAccessor.set

  @accessor 'iconpause',
    get: -> @['iconpause'] ? 'pause'
    set: Batman.Property.defaultAccessor.set

  @accessor 'iconstop',
    get: -> @['iconstop'] ? 'stop'
    set: Batman.Property.defaultAccessor.set

  @accessor 'icon-style', ->
    if @get('state') == 'playing' then 'dimmer-icon-on' else 'dimmer-icon-off'

  plusLevel: ->
    newLevel = parseInt(@get('level'))+1
    if newLevel > 100
      newLevel = 100
    else if newLevel < 0
      newLevel = 0
    @set 'level', newLevel
    return @get('level')

  minusLevel: ->
    newLevel = parseInt(@get('level'))-1
    if newLevel > 100
      newLevel = 100
    else if newLevel < 0
      newLevel = 0
    @set 'level', newLevel
    return @get('level')


  queryState: ->
    $.get '/homeassistant/mediaplayer',
      widgetId: @get('id'),
      (data) =>
        json = JSON.parse data
        console.log json
        @set 'state', json.state
        @set 'level', Math.round(json.attributes.volume_level * 100)

  playPause: ->
    $.post '/homeassistant/mediaplayerPlayPause',
      widgetId: @get('id'),
      (data) =>
        json = JSON.parse data
        if json.error != 0
          @toggleState()


  levelUp: ->
    newLevel = @plusLevel()
    console.log newLevel / 100.0
    $.post '/homeassistant/mediaplayerVolumeSet',
      widgetId: @get('id'),
      command: newLevel / 100.0,
      (data) =>
        json = JSON.parse data


  levelDown: ->
    newLevel = @minusLevel()
    console.log newLevel / 100.0
    $.post '/homeassistant/mediaplayerVolumeSet',
      widgetId: @get('id'),
      command: newLevel / 100.0,
      (data) =>
        json = JSON.parse data

  ready: ->
    if @get('bgcolor')
      $(@node).css("background-color", @get('bgcolor'))
      
  onData: (data) ->
    console.log "data", data

  onClick: (event) ->
    if event.target.id == "level-down"
      @levelDown()
    else if event.target.id == "level-up"
      @levelUp()
    else if event.target.id == "switch"
      @playPause()
