class Dashing.Haservice extends Dashing.ClickableWidget
  constructor: ->
    super

  @accessor 'icon',
    get: -> if @['icon'] then @['icon'] else 'send'
    set: Batman.Property.defaultAccessor.set

  postState: ->
    $.post '/homeassistant/service',
      service: @get('service'),
      payload: @get('payload'),
      (data) =>
        json = JSON.parse data

  ready: ->
    if @get('bgcolor')
      $(@node).css("background-color", @get('bgcolor'))

  onClick: (event) ->
    @postState()
