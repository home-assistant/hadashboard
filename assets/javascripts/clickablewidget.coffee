class Dashing.ClickableWidget extends Dashing.Widget
  constructor: ->
    super
    $(@node).on 'click', (evt) => @handleClick evt
    $(@node).on 'touchstart', (evt) => @handleTouchStart evt
    $(@node).on 'touchmove', (evt) => @handleTouchMove evt
    $(@node).on 'touchend', (evt) => @handleTouchEnd evt

  handleClick: (evt) ->
    @onClick evt

  handleTouchStart: (evt) ->
    evt.preventDefault()
    @onTouchStart evt

  handleTouchMove: (evt) ->
    @onTouchMove evt

  handleTouchEnd: (evt) ->
    @onTouchEnd evt
    @onClick evt

  onClick: (evt) ->
    # override for click events

  onTouchStart: (evt) ->
    # override for touchstart events

  onTouchMove: (evt) ->
    # override for touchmove events

  onTouchEnd: (evt) ->
    # override for touchend events
