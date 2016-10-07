class Dashing.Reload extends Dashing.ClickableWidget

  ready: ->
    if @get('bgcolor')
      $(@node).css("background-color", @get('bgcolor'))

  onData: (data) ->

  onClick: (event) ->
  	Dashing.fire 'reload'
