class Dashing.Hasetlevel extends Dashing.ClickableWidget
  constructor: ->
    super


   @accessor 'level',
    get: -> @_level ? "off"
    set: (key, value) -> @_level = value

  @accessor 'levellabel',
    get: -> if @get('level') != 'off' then @get('level') + '%' else 'Off'
    set: (key, value) -> @_level = value

  @accessor 'opacitylevel',
    get: -> if @get('level') == 'off' then '100 ; color:Black' else @get('level') / 100
    set: (key, value) -> @_opacitylevel = value

  postState: ->
    path = '/homeassistant/setdimmer'
    $.post path,
      command: @get('level'),


  ready: ->

  onData: (data) ->

  onClick: (node, event) ->
    @postState()
    Dashing.cycleDashboardsNow(
      boardnumber: @get('page'),
      stagger: @get('stagger'),
      fastTransition: @get('fasttransition'),
      transitiontype: @get('transitiontype'))
