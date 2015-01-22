class ReactiveList
  errors: []
  constructor: (@options)->
    @options.animationEngine = 'jquery'
    if TweenLite? && (@options.preferredEngine != 'jquery')
      @options.animationEngine = 'gsap'
      @options.easing ||= 'Power1.easeOut'

    @ValidateSettings()

  ValidateSettings: ->
    if @options.animationEngine == 'gsap' && @options.easing?
      knownEasings = ["Linear.easeNone", "Power0.easeIn", "Power0.easeInOut", "Power0.easeOut", "Power1.easeIn",
                      "Power1.easeInOut", "Power1.easeOut", "Power2.easeIn", "Power2.easeInOut", "Power2.easeOut",
                      "Power3.easeIn", "Power3.easeInOut", "Power3.easeOut", "Power4.easeIn", "Power4.easeInOut",
                      "Power4.easeOut", "Quad.easeIn", "Quad.easeInOut", "Quad.easeOut", "Cubic.easeIn",
                      "Cubic.easeInOut", "Cubic.easeOut", "Quart.easeIn", "Quart.easeInOut", "Quart.easeOut",
                      "Quint.easeIn", "Quint.easeInOut", "Quint.easeOut", "Strong.easeIn", "Strong.easeInOut",
                      "Strong.easeOut", "Back.easeIn", "Back.easeInOut", "Back.easeOut", "Bounce.easeIn",
                      "Bounce.easeInOut", "Bounce.easeOut", "Circ.easeIn", "Circ.easeInOut", "Circ.easeOut",
                      "Elastic.easeIn", "Elastic.easeInOut", "Elastic.easeOut", "Expo.easeIn", "Expo.easeInOut",
                      "Expo.easeOut", "Sine.easeIn", "Sine.easeInOut", "Sine.easeOut", "SlowMo.ease"]
      unless @options.easing in knownEasings
        @errors.push "You asked to use the #{@options.easing} easing for gsap, but this does not exist so using Power1.easeOut instead now, current valid easings are <code>#{knownEasings.join(", ")}</code>"
        @options.easing = 'Power1.easeOut'

    if @options.animationEngine == 'jquery' && @options.easing?
      if jQuery.easing[@options.easing] == undefined
        knownEasings = []
        for key of jQuery.easing
          knownEasings.push "<code>#{key}</code>"
        @errors.push "You asked to use the #{@options.easing} easing for jquery, but this does not exist so using linear instead now, current valid easings are #{knownEasings.join(", ")}, you can also add <code>meteor add jquery-easing</code> to get more of them"
        @options.easing = 'linear'

  ObserveCursor: (cursor) ->
    $self = this
    cursor.observe
      added: (doc)->
        $self.UpdateMappingCache(cursor)

      changed: (doc) ->
        $self.UpdateMappingCache(cursor)

      removed: (doc) ->
        try
          el = $("[data-reactive-list-item-id=#{doc._id}]")
          if $self.options.animationEngine == 'gsap'
            TweenLite.to item, $self.options.gsap.animationDuration, opacity: 0, ease: $self.options.easing, onComplete: ->
              el.remove()
          if $self.options.animationEngine == 'jquery'
            el.fadeOut $self.options.jquery.animationDuration, ->
              el.remove()
          else
            el.remove()

        $self.UpdateMappingCache(cursor)


  UpdateMappingCache: (cursor) ->
    @mappingCache = cursor.fetch().map (r)-> r._id
    for id in @mappingCache
      position = @IndexOfIdInCursor(id)
      el = $("[data-reactive-list-item-id=#{id}]")
      el.attr('data-reactive-list-position', position)

    @Order()

  IndexOfIdInCursor: (id) ->
    _.indexOf(@mappingCache, id)


  Order: _.throttle ->
    for el in $('.reactive-list')
      el = $(el)
      @MoveItemsFromContainerToList(el)
    @Animate()
  , 250

  Animate: () ->
    for el in $('.reactive-list')
      el = $(el)
      relativeOffset = 0
      elements = el.find('.reactive-list-item')
      for i in [0...elements.length]
        item = el.find("[data-reactive-list-position=#{i}]")
        if @options.animationEngine == 'gsap'
          TweenLite.to item, @options.gsap.animationDuration, css: {top: relativeOffset}, ease: @options.easing
        else if @options.animationEngine == 'jquery'
          item.animate {top: relativeOffset}, duration: @options.jquery.animationDuration, queue: false, easing: @options.easing
        else
          item.css 'top', relativeOffset

        relativeOffset += item.outerHeight(true)

      newUlHeight = relativeOffset + 2
      if @options.animationEngine == 'gsap'
        TweenLite.to el, @options.gsap.animationDuration, height: newUlHeight, ease: @options.easing
      else if @options.animationEngine == 'jquery'
        el.animate {height: newUlHeight}, duration: @options.jquery.animationDuration, queue: false, easing: @options.easing
      else
        el.css 'height', newUlHeight

  MoveItemsFromContainerToList: (el)->
    container = el.prev()
    for item in container.find('.reactive-list-item')
      item = $(item)
      if @options.animationEngine == 'gsap'
        TweenLite.to item, 0, opacity: 0
        el.append(item)
        TweenLite.to item, @options.gsap.animationDuration, opacity: 1, ease: @options.easing
      if @options.animationEngine == 'jquery'
        item.hide()
        el.append(item)
        item.fadeIn @options.jquery.animationDuration
      else
        el.append(item)

Template.reactiveListItem.helpers
  listStyle: ->
    Template.parentData(1)._ReactiveList.options.layout=='list'

  tableStyle: ->
    Template.parentData(1)._ReactiveList.options.layout=='table'

  positionInCursor: ->
    Template.parentData(1)._ReactiveList.IndexOfIdInCursor(@_id)

  template: -> Template.parentData(1).template

Template.reactiveListItem.rendered = ->
  Template.parentData(1)._ReactiveList.Order()

Template.reactiveList.helpers
  hasErrors: ->
    @_ReactiveList.errors.length

  errors: ->
    return unless @_ReactiveList.errors.length
    items = []
    for error in @_ReactiveList.errors
      items.push $('<li/>').html(error).prop('outerHTML')
    items.join("")

  cursor: ->
    @_ReactiveList.ObserveCursor(@cursor)
    @cursor

  listStyle: ->
    @_ReactiveList.options.layout=='list'

  tableStyle: ->
    @_ReactiveList.options.layout=='table'

  template: -> @template

Template.reactiveList.created = ->
  options = {gsap: {}, jquery: {}}
  options.layout = @data?.layout || 'list'
  options.gsap.animationDuration = @data?.animationDuration || 0.3 #we use seconds , as does gasp
  options.jquery.animationDuration = (@data?.animationDuration || 0.3) * 1000 #we use seconds , jquery is in ms
  options.easing = @data?.easing
  options.preferredEngine = @data?.engine
  @data._ReactiveList = new ReactiveList(options)
