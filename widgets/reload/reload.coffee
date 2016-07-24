class Dashing.Reload extends Dashing.ClickableWidget

  ready: ->
    if @get('bgcolor')
      $(@node).css("background-color", @get('bgcolor'))
    else
      $(@node).css("background-color", "#444")

  onData: (data) ->

  onClick: (event) ->
  	Dashing.fire 'reload'
