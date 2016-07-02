class Dashing.Haweather extends Dashing.Widget
  constructor: ->
    super
    @_icons =
      rain: '&#xe009',
      snow: '&#xe036',
      sleet: '&#xe003',
      wind: '&#xe021',
      fog: '&#xe01b',
      cloudy: '&#xe000',
      clear_day: '&#xe028',
      clear_night: '&#xe02d',
      partly_cloudy_day: '&#xe001',
      partly_cloudy_night: '&#xe002'

  @accessor 'climacon', ->
    new Batman.TerminalAccessible (attr) =>
      @_icons[attr]

  @accessor 'now_temp',
    get: -> if @_temp then Math.floor(@_temp) else 0
    set: (key, value) -> @_temp = value

  ready: ->
    if @get('bgcolor')
      $(@node).css("background-color", @get('bgcolor'))
    else
      $(@node).css("background-color", "#444")
      
  onData: (data) ->
