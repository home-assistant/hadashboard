# Flying Widgets v0.1.1
#
# To use, put this file in assets/javascripts/cycleDashboard.coffee.  Then find this line in
# application.coffee:
#
#         $('.gridster ul:first').gridster
#
# And change it to:
#
#         $('.gridster > ul').gridster
#
# Finally, put multiple gridster divs in your dashboard, and add a call to Dashing.cycleDashboards()
# to the javascript at the top of your dashboard:
#
#     <script type='text/javascript'>
#     $(function() {
#       Dashing.widget_base_dimensions = [370, 340]
#       Dashing.numColumns = 5
#       Dashing.cycleDashboards({timeInSeconds: 15, stagger: true});
#     });
#     </script>
#
#     <% content_for :title do %>Loop Dashboard<% end %>
#
#     <div class="gridster">
#       <ul>
#         <!-- Page 1 of widgets goes here. -->
#         <li data-row="1" data-col="1" data-sizex="1" data-sizey="1">
#           <div data-view="Image" data-image="/inverted-logo.png" style="background-color:#666766"></div>
#         </li>
#
#       </ul>
#     </div>
#
#     <div class="gridster">
#       <ul>
#         <!-- Page 2 of widgets goes here. -->
#       </ul>
#     </div>
#
 
# Some generic helper functions
sleep = (timeInSeconds, fn) -> setTimeout fn, timeInSeconds * 1000
isArray = (obj) -> Object.prototype.toString.call(obj) is '[object Array]'
isString = (obj) -> Object.prototype.toString.call(obj) is '[object String]';
isFunction = (obj) -> obj && obj.constructor && obj.call && obj.apply
 
#### Show/Hide functions.
#
# Every member of `showFunctions` and `hideFunctions` must be one of:
#
# * A `{start, end, transition}` object (transition defaults to 'all 1s'.)
# * A `{transitionFunction}` object.
# * A `fn($dashboard, widget, originalLocations)` which returns one of the above.
#
# The easiest way to define a transition is just to specify start and end CSS proprties for each
# widget with a `{start, end}` object.  The `fadeOut` and `fadeIn` are some of the simplest
# examples below.  Sometimes you might need slightly more control, in which case `start` and
# `end` can each be functions of the form `($widget, index)`, where $widget is the jquery object
# for the widget being transformed, and index is the index of the widget within the dashboard.
# The function form is handy when you want to do something different for each widget, depending
# on it's location.
#
# For even more control, you can specify a `fn($dashboard, widgets, originalLocations)` function
# in place of the entire object.  This is handy when you have some setup work to do for your
# transition, such as detecting the width of the page so you can move all widgets off-screen.
#
# For the ultimate in control, you can specify a
# `transitionFunction{$dashboard, options, done}` object.  It will be up to you to
# do whatever you need to do in order to hide or display the dashboard.  The CSS of every widget
# will be reset to something sane when the function completes, but otherwise it's entirely
# up to you.  Params are:
#
# * `$dashboard` - jquery object of the dashboard to show/hide.
# * `options.stagger` - True if transition should be staggered.
# * `options.widgets` - An array of all widgets in the dashboard.
# * `options.originalLocations` - An array of CSS data about the location, opacity, etc... of
#   each widget.
# * `done()` - Async callback.  Make sure you call this!
#
 
hideFunctions = {
	# toRight: ($dashboard, widgets, originalLocations) ->
		# documentWidth = $(document).width()
		# return {end: (($widget) -> {left: documentWidth, opacity: 0})}
 
	# shrink: {
		# start: {
			# opacity: 1,
			# transform: 'scale(1,1)',
			# "-webkit-transform": 'scale(1,1)'
		# },
		# end: {
			# transform: 'scale(0,0)',
			# "-webkit-transform": 'scale(0,0)',
			# opacity: 0
		# }
	# }
 
	fadeOut: {
		start: {opacity: 1}
		end: {opacity: 0}
	}
 
	# explode: {
		# start: {
			# opacity: 1
			# transform: 'scale(1,1)',
			# "-webkit-transform": 'scale(1,1)'
		# }
		# end: {
			# opacity: 0
			# transform: 'scale(2,2)',
			# "-webkit-transform": 'scale(2,2)'
		# }
	# }
}
 
# Handy function for reversing simple transitions
reverseTransition = (obj) ->
	if isFunction(obj) or obj.transitionFunction?
		throw new Error("Can't reverse transition")
	return {start: obj.end, end: obj.start, transition: obj.transition}
 
showFunctions = {
	# fromLeft: ($dashboard, widgets, originalLocations) ->
		# start: (($widget, index) -> {left: "#{-$widget.width() - $dashboard.width()}px", opacity: 0}),
		# end: (($widget, index) -> originalLocations[index]),
 
	# fromTop: ($dashboard, widgets, originalLocations) ->
		# start: (($widget, index) -> {top: "#{-$widget.height() - $dashboard.height()}px", opacity: 0}),
		# end: (($widget, index) -> return originalLocations[index]),
 
	# zoom: reverseTransition(hideFunctions.shrink)
 
	fadeIn: reverseTransition(hideFunctions.fadeOut)
 
	# implode: reverseTransition(hideFunctions.explode)
 
}
 
# Move an element from one place to another using a CSS3 transition.
#
# * `elements` - One or more elements to move, in an array.
# * `transition` - The transition string to apply (e.g.: 'left 1s ease 0s')
# * `start` - This can be an object (e.g. `{left: 0px}`) or a `fn($el, index)`
#   which returns such an object.  This is the location the object will start at.
#   If start is omitted, then the current location of the object will be used
#   as the start.
# * `end` - As with `start`, this can be an object or a function.  `end` is required.
# * `timeInSeconds` - The time required to complete the transition.  This function will
#   wait this long before calling `done()`.
# * `offset` is an offset for the index passed into `start()` and `end()`.  Handy when
#   you want to split up an array of
# * `done()` - Async callback.
moveWithTransition = (elements, {transition, start, end, timeInSeconds, offset}, done) ->
	transition = transition or ''
	timeInSeconds = timeInSeconds or 0
	end = end or {}
	offset = offset or 0
 
	origTransitions = []
	moveToStart = () ->
		for el, index in elements
			$el = $(el)
			origTransitions[index + offset] = $el.css 'transition'
			$el.css transition: 'left 0s ease 0s'
			$el.css(if isFunction start then start($el, index + offset) else start)
 
	moveToEnd = () ->
		for el, index in elements
			$el = $(el)
			$el.css transition: transition
			$el.css(if isFunction end then end($el, index + offset) else end)
		sleep Math.max(0, timeInSeconds), ->
			$el.css transition: origTransitions[index + offset]
			done? null
 
	if start
		moveToStart()
		sleep 0, -> moveToEnd()
	else
		moveToEnd()
 
# Runs a function which shows or hides the dashboard.  This function ensures that all the
# dashboards widgets end up where they started.
#
# Transitions should be a `{start, end}` object suitable for passing to moveWithTransition,
# or a `transitions($dashboard, widgets, originalLocations)` function which returns such an object.
#
showHideDashboard = (visible, stagger, $dashboard, transitions, done) ->
	$dashboard = $($dashboard)
 
	$ul = $dashboard.children('ul')
	$widgets = $ul.children('li')
 
	# Record the original location, opacity, other CSS attributes we might want to edit
	originalLocations = []
	$widgets.each (index, widget) ->
		$widget = $(widget)
		originalLocations[index] = {
			left: $widget.css 'left'
			top: $widget.css 'top'
			width: $widget.css 'width'
			height: $widget.css 'height'
			opacity: $widget.css 'opacity'
			transform: $widget.css 'transform'
			"-webkit-transform": $widget.css '-webkit-transform'
		}
 
	widgets = $.makeArray($widgets)
 
	if isFunction transitions
		transitions = transitions($dashboard, widgets, originalLocations)
 
 
	origDone = done
	done = () ->
		sleep 0, () ->
			# Make sure the dashboard is in a sane state.
			$dashboard.toggle( visible )
 
			sleep 0, () ->
				# Clear any styles we've set on the widgets.
				#
				# TODO: It would be nice to record the styles before we start, and then restore them
				# here, but I've found that if my laptop goes to sleep, when it wakes up, when
				# displaying the dashboard on Chrome, it sometimes picks up bad values for
				# `originalLocations`.  By always forcing the style to a sane known value, we know
				# everything will work out in the end.
				#
				$dashboard.children('ul').children('li').attr 'style', 'position: absolute'
 
				origDone?()
 
 
	transitionString = "all 1s"
 
	if transitions.transitionFunction
		# Show/hide the dashboard with a custom function
		transitionFunction = transitions.transitionFunction
 
	else if !stagger
		transitionFunction = ($dashboard, {widgets, originalLocations}, fnDone) ->
			moveWithTransition widgets, {
				end: transitions.start
			}, -> sleep 0, ->
				if visible then $dashboard.show()
				moveWithTransition widgets, {
					start: transitions.start,
					end: transitions.end,
					transition: transitions.transition or transitionString,
					timeInSeconds: 1
				}, fnDone
 
	else
		transitionFunction = ($dashboard, {widgets, originalLocations}, fnDone) ->
			singleWidgetFn = (widget, index) ->
				moveWithTransition [widget], {
					end: transitions.start,
					offset: index
				}, -> sleep 0, ->
					if visible then $dashboard.show()
					sleep (Math.random()/2), () ->
						moveWithTransition [widget], {
							start: transitions.start,
							end: transitions.end,
							transition: transitions.transition or transitionString,
							timeInSeconds: 1,
							offset: index
						}, ->
			for widget, index in widgets
				singleWidgetFn(widget, index)
 
			sleep 1.5, fnDone
 
	# Show or hide the dashboard
	transitionFunction $dashboard, {stagger, widgets, originalLocations}, done
 
# Select a member at random from an object.
#
# If 'allowedMembers' is an array of strings, then only the corresponding members will be
# considered for selection.
#
# Returns a "{key, value}" object.
pickMember = (object, allowedMembers=null) ->
	answer = null
	functionArray = []
	if allowedMembers?
		if not isArray allowedMembers then allowedMembers = [allowedMembers]
		for memberName in allowedMembers
			if memberName of object then functionArray.push {key: memberName, value: object[memberName]}
	else
		for memberName, member of object
			functionArray.push {key: memberName, value: member}
 
	if functionArray.length > 0
		index = Math.floor(Math.random()*functionArray.length);
		answer = functionArray[index]
 
	return answer
 
# Cycle the dashboard to the next dashboard.
#
# If a transition is already in progress, this function does nothing.
Dashing.cycleDashboardsNow = do () ->
	transitionInProgress = false
	visibleIndex = 0
	(options = {}) ->
		return if transitionInProgress
		transitionInProgress = true
 
		{stagger, fastTransition, boardnumber, transitiontype} = options
		stagger = !!stagger
		fastTransition = !!fastTransition
 
		$dashboards = $('.gridster')
 
		# Work out which dashboard to show		
		oldVisibleIndex = visibleIndex
		if boardnumber?
			visibleIndex = boardnumber - 1
		else
			visibleIndex++
			if visibleIndex >= $dashboards.length
				visibleIndex = 0

		if oldVisibleIndex == visibleIndex
			# Only one dashboard.  Disable fast transitions
			fastTransition = false
 
		doneCount = 0
		doneFn = () ->
			doneCount++
			# Only set transitionInProgress to false when both the show and the hide functions
			# are finished.
			if doneCount is 2
				transitionInProgress = false
 
		# Hide the old dashboard
		hideFunction = pickMember hideFunctions
 
		showNewDashboard = () ->
			options.onTransition?($($dashboards[visibleIndex]))
			showFunction = null
			chainsTo = hideFunction.value.chainsTo
			if isString chainsTo
				showFunction = showFunctions[chainsTo]
			else if chainsTo?
				showFunction = {key: "chainsTo", value: chainsTo}
 
			if !showFunction
				showFunction = pickMember showFunctions
 
			# console.log "Showing dashboard #{visibleIndex} #{showFunction.key}"
			showHideDashboard true, stagger, $dashboards[visibleIndex], showFunction.value, () ->
				doneFn()
 
		# console.log "Hiding dashboard #{oldVisibleIndex} #{hideFunction.key}"
		showHideDashboard false, stagger, $dashboards[oldVisibleIndex], hideFunction.value, () ->
			if !fastTransition
				showNewDashboard()
			doneFn()
 
		# If fast transitions are enabled, then don't wait for the hiding animation to complete
		# before showing the new dashboard.
		if fastTransition then showNewDashboard()
 
		return null
 
# Adapted from http://stackoverflow.com/questions/1403888/get-url-parameter-with-javascript-or-jquery
getURLParameter = (name) ->
	encodedParameter = (RegExp(name + '=' + '(.+?)(&|$)').exec(location.search)||[null,null])[1]
	return if encodedParameter? then decodeURI(encodedParameter) else null
 
# Cause dashing to cycle from one dashboard to the next.
#
# Dashboard cycling can be bypassed by passing a "page" parameter in the url.  For example,
# going to http://dashboardserver/mydashboard?page=2 will show the second dashboard in the list
# and will not cycle.
#
# Options:
# * `timeInSeconds` - The time to display each dashboard, in seconds.  If 0, then dashboards will
#   not automatically cycle, but can be cycled manually by calling `cycleDashboardsNow()`.
# * `stagger` - If this is true, each widget will be transitioned individually at slightly
#   randomized times.  This gives a more random look.  If false, then all wigets will be moved
#   at the same time.  Note if `timeInSeconds` is 0, then this option is ignored (but can, instead,
#   be passed to `cycleDashboardsNow()`.)
# * `fastTransition` - If true, then we will run the show and hide transitions simultaneously.
#   This gets your new dashboard up onto the screen faster.
# * `onTransition($newDashboard)` - A function to call before a dashboard is displayed.
#
Dashing.cycleDashboards = (options) ->
	timeInSeconds = if options.timeInSeconds? then options.timeInSeconds else 20
 
	$dashboards = $('.gridster')
 
	startDashboard = if options.page? then options.page else 1
	startDashboard = Math.max startDashboard, 1
	startDashboard = Math.min startDashboard, $dashboards.length
 
	$dashboards.each (dashboardIndex, dashboard) ->
		# Hide all but the first dashboard.
		$(dashboard).toggle(dashboardIndex is (startDashboard - 1))
 
		# Set all dashboards to position: absolute so they stack one on top of the other
		$(dashboard).css "position": "absolute"
 
	# If the user specified a dashboard, then don't cycle from one dashboard to the next.
	if !startDashboardParam? and (timeInSeconds > 0)
		cycleFn = () -> Dashing.cycleDashboardsNow(options)
		setInterval cycleFn, timeInSeconds * 1000
 
	$(document).keypress (event) ->
		# Cycle to next dashboard on space
		if event.keyCode is 32 then Dashing.cycleDashboardsNow(options)
		return true
 
# Customized version of `Dashing.gridsterLayout()` which supports multiple dashboards.
Dashing.cycleGridsterLayout = (positions) ->
	#positions = positions.replace(/^"|"$/g, '') # ??
	positions = JSON.parse(positions)
	$dashboards = $(".gridster > ul")
	if isArray(positions) and ($dashboards.length == positions.length)
		Dashing.customGridsterLayout = true
		for position, index in positions
			$dashboard = $($dashboards[index])
			widgets = $dashboard.children("[data-row^=]")
			for widget, index in widgets
				$(widget).attr('data-row', position[index].row)
				$(widget).attr('data-col', position[index].col)
	else
		console.log "Warning: Could not apply custom layout!"
 
# Redefine functions for saving layout
sleep 0.1, () ->
	Dashing.getWidgetPositions = ->
		dashboardPositions = []
		for dashboard in $(".gridster > ul")
			dashboardPositions.push $(dashboard).gridster().data('gridster').serialize()
		return dashboardPositions
 
	Dashing.showGridsterInstructions = ->
		newWidgetPositions = Dashing.getWidgetPositions()
 
		if !isArray(newWidgetPositions[0])
			$('#save-gridster').slideDown()
			$('#gridster-code').text("
				Something went wrong - reload the page and try again.
			")
		else
			unless JSON.stringify(newWidgetPositions) == JSON.stringify(Dashing.currentWidgetPositions)
				Dashing.currentWidgetPositions = newWidgetPositions
				$('#save-gridster').slideDown()
				$('#gridster-code').text("
				  <script type='text/javascript'>\n
				  $(function() {\n\n
				  \ \ Dashing.cycleGridsterLayout('#{JSON.stringify(Dashing.currentWidgetPositions)}')\n
				  });\n
				  </script>
				")