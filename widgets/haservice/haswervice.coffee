class Dashing.Haservice extends Dashing.ClickableWidget
  constructor: ->
    super

  @accessor 'icon',
    get: -> if @['icon'] then @['icon'] else 'send'
    set: Batman.Property.defaultAccessor.set

  postState: ->
    $.post '/homeassistant/switch',
      payload: JSON.parse @get('payload'),
      service: @get('service'),
      (data) =>
        json = JSON.parse data

  ready: ->
    if @get('bgcolor')
      $(@node).css("background-color", @get('bgcolor'))

  onClick: (event) ->
    @postState()
