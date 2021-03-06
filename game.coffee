class Habitat
  constructor: (@game, attrs = {}) ->
    @[k] = v for k, v of attrs

class Blip
  constructor: (@game, @attrs = {}) ->
    @[k] = v for k, v of @attrs

  live: ->
    destination = null
    destDistance = 1/0
    for h in @game.habitats
      d = @circle.touchDistance(h.circle)
      if d < destDistance
        destination = h
        destDistance = d
    if destination?
      goTowards = destination.circle.center
      goVector = goTowards.minus(@circle.center)
      goVector = goVector.withMagnitude Math.min(@speed, goVector.magnitude())
      @circle = @circle.move goVector
      for b in @game.blips
        if b isnt @
          @circle = @circle.pushBack(b.circle)
    if @inHabitat()
      @health = Math.min(@maxHealth, @health + 1)
      if @health / @maxHealth > 0.95 and Math.random() > 0.99
        clone = new Blip(@game, @attrs)
        clone.circle = @circle
        @health /= 2
        clone.health = @health
        @game.newBlips.push(clone)
        @game.births++
    else
      @health -= 1
    if @health <= 0
      @game.deaths++
      false
    else
      true

  inHabitat: ->
    for h in @game.habitats
      return true if @circle.inside(h.circle)
    false

class Circle
  constructor: (attrs = {}) ->
    @[k] = v for k, v of attrs

  # Returns the shortest distance between the two circles.
  # If 0, the circles are exactly touching.
  # If less than 0, the circles are overlapping.
  touchDistance: (other) ->
    @centerDistance(other) - @radius - other.radius

  # The distance between 2 circles' centers.
  centerDistance: (other) ->
    @center.distance(other.center)

  # True if this circle is completely enclosed inside the other circle.
  inside: (other) ->
    @radius <= other.radius and @centerDistance(other) < other.radius - @radius

  move: (v) ->
    new Circle
      center: @center.plus(v)
      radius: @radius

  # Moves this circle so it's not overlapping the other one. (Mostly.)
  pushBack: (other) ->
    d = @touchDistance(other)
    return @ if d >= 0
    @move V2Polar(-d, @center.minus(other.center).angle() + Math.random() - 0.5)

class V2
  constructor: (@x, @y) ->

  plus: ({x, y}) ->
    new V2(@x + x, @y + y)

  minus: ({x, y}) ->
    new V2(@x - x, @y - y)

  times: ({x, y}) ->
    new V2(@x * x, @y * y)

  distance: ({x, y}) ->
    Math.sqrt((@x - x) ** 2 + (@y - y) ** 2)

  magnitude: ->
    @distance new V2(0, 0)

  angle: ->
    Math.atan2 @y, @x

  withMagnitude: (r) ->
    V2Polar(r, @angle())

  withAngle: (theta) ->
    V2Polar(@magnitude(), theta)

V2Polar = (r, theta) ->
  new V2(r * Math.cos(theta), r * Math.sin(theta))

class Game
  constructor: (@canvas) ->
    @ctx = canvas.getContext '2d'
    @habitats =
      [ new Habitat(@,
        circle: new Circle
          center: new V2(35, 35)
          radius: 40
        )
      , new Habitat(@,
        circle: new Circle
          center: new V2(0, 0)
          radius: 20
        )
      , new Habitat(@,
        circle: new Circle
          center: new V2(-70, 0)
          radius: 40
        )
      ]
    @blips =
      for x in [10..35] by 5
        new Blip(@,
          circle: new Circle
            center: new V2(x, 0)
            radius: 5
          speed: 1
          breed: [300, 400, 500, 600, 700]
          maxHealth: 150
          health: 100
        )
    @center = new V2 0, 0
    @zoom = 3
    @births = 0
    @deaths = 0

  drawCircle: (x, y, r, fill) ->
    @ctx.beginPath()
    @ctx.arc x, y, r, 0, 2 * Math.PI, false
    @ctx.fillStyle = fill
    @ctx.fill()

  draw: ->
    @ctx.fillStyle = '#ddb'
    @ctx.fillRect 0, 0, @canvas.width, @canvas.height
    canvasCenter = new V2(@canvas.width * 0.5, @canvas.height * 0.5)
    for h in @habitats
      {x, y} = h.circle.center.minus(@center).times(new V2 @zoom, @zoom).plus(canvasCenter)
      r = h.circle.radius * @zoom
      @drawCircle x, y, r, '#05a'
    for b in @blips
      {x, y} = b.circle.center.minus(@center).times(new V2 @zoom, @zoom).plus(canvasCenter)
      r = b.circle.radius * @zoom
      @ctx.globalAlpha = b.health / (b.maxHealth * 0.85)
      @drawCircle x, y, r, if b.inHabitat() then '#1a5' else '#633'
      @ctx.globalAlpha = 1
    @ctx.fillStyle = 'black'
    @ctx.font = '20px monospace'
    @ctx.fillText "Viewing (#{@center.x.toFixed(3)}, #{@center.y.toFixed(3)})", 10, 25
    @ctx.fillText "#{@births} births, #{@deaths} deaths", 10, 50

  mousedown: (@clickPosn) ->
    @clickCenter = @center

  mousemove: (posn) ->
    if @clickPosn?
      offset = posn.minus(@clickPosn).times(new V2(1 / @zoom, 1 / @zoom))
      @center = @clickCenter.minus(offset)
      @draw()

  mouseup: (posn) ->
    @mousemove posn
    delete @clickPosn

  tick: ->
    @newBlips = []
    @blips =
      b for b in @blips when b.live()
    @blips = @blips.concat(@newBlips)

$(document).ready ->
  canvas = $('#the-canvas')[0]
  window.game = new Game canvas
  handle = (mouseEvent) -> (e) ->
    {left, top} = $('#the-canvas').offset()
    window.game[mouseEvent] new V2(e.pageX - left, e.pageY - top)
  $('#the-canvas').mousedown handle('mousedown')
  $(document).mousemove handle('mousemove')
  $(document).mouseup handle('mouseup')
  resize = ->
    canvas.width = $(window).width()
    canvas.height = $(window).height()
  resize()
  $(window).resize -> resize()
  (gameLoop = ->
    window.game.tick()
    window.game.draw()
    requestAnimationFrame gameLoop
  )()
