class Habitat
  constructor: (@posn, @radius) ->

class Blip
  constructor: (@posn, @radius) ->

class V2
  constructor: (@x, @y) ->

  plus: ({x, y}) ->
    new V2(@x + x, @y + y)

  minus: ({x, y}) ->
    new V2(@x - x, @y - y)

  times: ({x, y}) ->
    new V2(@x * x, @y * y)

class Game
  constructor: (@canvas) ->
    @ctx = canvas.getContext '2d'
    @habitats = [new Habitat(new V2(35, 35), 30)]
    @blips = [new Blip(new V2(0, 0), 5)]
    @center = new V2 0, 0
    @zoom = 3

  drawCircle: (x, y, r, fill) ->
    @ctx.beginPath()
    @ctx.arc x, y, r, 0, 2 * Math.PI, false
    @ctx.fillStyle = fill
    @ctx.fill()

  draw: ->
    @ctx.fillStyle = '#888'
    @ctx.fillRect 0, 0, @canvas.width, @canvas.height
    canvasCenter = new V2(@canvas.width * 0.5, @canvas.height * 0.5)
    for h in @habitats
      {x, y} = h.posn.minus(@center).times(new V2 @zoom, @zoom).plus(canvasCenter)
      r = h.radius * @zoom
      @drawCircle x, y, r, '#33a'
    for b in @blips
      {x, y} = b.posn.minus(@center).times(new V2 @zoom, @zoom).plus(canvasCenter)
      r = b.radius * @zoom
      @drawCircle x, y, r, '#a33'
    @ctx.strokeStyle = 'black'
    @ctx.strokeRect 0, 0, @canvas.width, @canvas.height

$(document).ready ->
  canvas = $('#the-canvas')[0]
  canvas.width = 640
  canvas.height = 480
  window.game = new Game canvas
  window.game.draw()