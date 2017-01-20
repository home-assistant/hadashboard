class Dashing.Hagraph extends Dashing.Widget

  constructor: ->
    super
    @queryState()

  @accessor 'value',
    get: -> if @_value then (if isNaN(Math.round(@_value)) then @_value else @_value ) else "??"
    set: (key, value) -> 
      if typeof @_value is 'undefined'
        today = new Date
        @_old_x=Math.round(today.getTime()/1000)
        @_my_list = [{x: @_old_x, y: parseFloat(value)}]
        @_value = value
      else
        today = new Date
        @_old_x=Math.round(today.getTime()/1000)
        @_my_list.push ({x: @_old_x, y: parseFloat(value)})
        @_value = value
      if typeof @graph isnt 'undefined'
        @graph.series[0].data = @_my_list
        @graph.render()
      
  queryState: ->
    $.get '/homeassistant/sensor',
      widgetId: @get('id'),
      deviceId: @get('device')
      (data) =>
        json = JSON.parse data
        @set 'value', json.value

  ready: ->
    if @get('bgcolor')
      $(@node).css("background-color", @get('bgcolor'))
    else
      $(@node).css("background-color", "#444")
    container = $(@node).parent()
    # Gross hacks. Let's fix this.
    width = (Dashing.widget_base_dimensions[0] * container.data("sizex")) + Dashing.widget_margins[0] * 2 * (container.data("sizex") - 1)-10
    height = (Dashing.widget_base_dimensions[1] * container.data("sizey"))-55
    @graph = new Rickshaw.Graph(
      element: @node
      width: width
      height: height
      renderer: @get('renderer')
      series: [
        {
        color: "#000",
        data: @_my_list
        }
      ]
    )

    @graph.series[0].data = @get('points') if @get('points')

    x_axis = new Rickshaw.Graph.Axis.Time(graph: @graph)
    y_axis = new Rickshaw.Graph.Axis.Y(graph: @graph, tickFormat: Rickshaw.Fixtures.Number.formatKMBT)
    @graph.render()

  onData: (data) ->
    #if @graph
    #  @graph.render()
