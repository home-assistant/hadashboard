class Dashing.Hascene extends Dashing.ClickableWidget
  constructor: ->
    super
    @queryState()

  @accessor 'icon',
    get: -> @['icon'] ? 'square'
    set: Batman.Property.defaultAccessor.set

  @accessor 'icon-style', ->
    if @isModeSet() then 'icon-active' else 'icon-inactive'

  @accessor 'mode',
    get: -> @_mode ? 'Unknown'
    set: (key, value) -> @_mode = value

  @accessor 'countdown',
    get: -> @_countdown ? 0
    set: (key, value) -> @_countdown = value

  @accessor 'timer',
    get: -> @_timer ? 0
    set: (key, value) -> @_timer = value

  showTimer: ->
    $(@node).find('.icon').hide()
    $(@node).find('.timer').show()

  showIcon: ->
    $(@node).find('.timer').hide()
    $(@node).find('.icon').show()

  isModeSet: ->
    @get('mode') == @get('changemode')

  queryState: ->
    $.get '/homeassistant/scene',
      widgetId: @get('id'),
      input: 'input'
      (data) =>
        json = JSON.parse data
        @set 'mode', json.mode

  postModeState: ->
    oldMode = @get 'mode'
    @set 'mode', @get('changemode')
    $.post '/homeassistant/scene',
      widgetId: @get('id'),
      (data) =>
        json = JSON.parse data
        if json.error != 0
          @set 'mode', oldModeM

  postPhraseState: ->
    $.post '/smartthings/dispatch',
      deviceType: 'phrase',
      phrase: @get('phrase')
      (data) =>
        @queryState()

  ready: ->
    @showIcon()

  onData: (data) ->

  changeModeDelayed: =>
    if @get('timer') <= 0
      @showIcon()
      if @get('phrase')
        @postPhraseState()
      else
        @postModeState()
      @_timeout = null
    else
      @showTimer()
      @set 'timer', @get('timer') - 1
      @_timeout = setTimeout(@changeModeDelayed, 1000)

  onClick: (event) ->
    if not @_timeout and not @isModeSet()
      @set 'timer', @get('countdown')
      @changeModeDelayed()
