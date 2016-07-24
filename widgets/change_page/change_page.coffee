class Dashing.ChangePage extends Dashing.Widget

  ready: ->
    if @get('bgcolor')
      $(@node).css("background-color", @get('bgcolor'))
    else
      $(@node).css("background-color", "#444")

  onData: (data) ->

  onClick: (node, event) ->
  	Dashing.cycleDashboardsNow(boardnumber: @get('page'), stagger: @get('stagger'), fastTransition: @get('fasttransition'), transitiontype: @get('transitiontype'))
