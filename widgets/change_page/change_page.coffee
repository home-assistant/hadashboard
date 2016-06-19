class Dashing.ChangePage extends Dashing.Widget

  ready: ->

  onData: (data) ->

  onClick: (node, event) ->
  	Dashing.cycleDashboardsNow(boardnumber: @get('page'), stagger: @get('stagger'), fastTransition: @get('fasttransition'), transitiontype: @get('transitiontype'))
