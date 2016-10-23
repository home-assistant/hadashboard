class Dashing.News extends Dashing.Widget

  ready: ->
    @currentIndex = 0
    @headlineElem = $(@node).find('.headline-container')
    @nextComment()
    @startCarousel()
    if @get('bgcolor')
      $(@node).css("background-color", @get('bgcolor'))

  onData: (data) ->
    @currentIndex = 0

  startCarousel: ->
    interval = $(@node).attr('data-interval')
    interval = "30" if not interval
    setInterval(@nextComment, parseInt( interval ) * 1000)

  nextComment: =>
    headlines = @get('headlines')
    if headlines
      @headlineElem.fadeOut =>
        @currentIndex = (@currentIndex + 1) % headlines.length
        @set 'current_headline', headlines[@currentIndex]
        @headlineElem.fadeIn()
