// Generated by CoffeeScript 1.8.0
(function() {
  var Blip, Game, Habitat, V2;

  Habitat = (function() {
    function Habitat(posn, radius) {
      this.posn = posn;
      this.radius = radius;
    }

    return Habitat;

  })();

  Blip = (function() {
    function Blip(posn, radius) {
      this.posn = posn;
      this.radius = radius;
    }

    return Blip;

  })();

  V2 = (function() {
    function V2(x, y) {
      this.x = x;
      this.y = y;
    }

    V2.prototype.plus = function(_arg) {
      var x, y;
      x = _arg.x, y = _arg.y;
      return new V2(this.x + x, this.y + y);
    };

    V2.prototype.minus = function(_arg) {
      var x, y;
      x = _arg.x, y = _arg.y;
      return new V2(this.x - x, this.y - y);
    };

    V2.prototype.times = function(_arg) {
      var x, y;
      x = _arg.x, y = _arg.y;
      return new V2(this.x * x, this.y * y);
    };

    return V2;

  })();

  Game = (function() {
    function Game(canvas) {
      this.canvas = canvas;
      this.ctx = canvas.getContext('2d');
      this.habitats = [new Habitat(new V2(35, 35), 30)];
      this.blips = [new Blip(new V2(0, 0), 5)];
      this.center = new V2(0, 0);
      this.zoom = 3;
    }

    Game.prototype.drawCircle = function(x, y, r, fill) {
      this.ctx.beginPath();
      this.ctx.arc(x, y, r, 0, 2 * Math.PI, false);
      this.ctx.fillStyle = fill;
      return this.ctx.fill();
    };

    Game.prototype.draw = function() {
      var b, canvasCenter, h, r, x, y, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3;
      this.ctx.fillStyle = '#888';
      this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
      canvasCenter = new V2(this.canvas.width * 0.5, this.canvas.height * 0.5);
      _ref = this.habitats;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        h = _ref[_i];
        _ref1 = h.posn.minus(this.center).times(new V2(this.zoom, this.zoom)).plus(canvasCenter), x = _ref1.x, y = _ref1.y;
        r = h.radius * this.zoom;
        this.drawCircle(x, y, r, '#33a');
      }
      _ref2 = this.blips;
      for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
        b = _ref2[_j];
        _ref3 = b.posn.minus(this.center).times(new V2(this.zoom, this.zoom)).plus(canvasCenter), x = _ref3.x, y = _ref3.y;
        r = b.radius * this.zoom;
        this.drawCircle(x, y, r, '#a33');
      }
      this.ctx.strokeStyle = 'black';
      return this.ctx.strokeRect(0, 0, this.canvas.width, this.canvas.height);
    };

    Game.prototype.mousedown = function(clickPosn) {
      this.clickPosn = clickPosn;
      return this.clickCenter = this.center;
    };

    Game.prototype.mousemove = function(posn) {
      var offset;
      if (this.clickPosn != null) {
        offset = posn.minus(this.clickPosn).times(new V2(1 / this.zoom, 1 / this.zoom));
        this.center = this.clickCenter.minus(offset);
        return this.draw();
      }
    };

    Game.prototype.mouseup = function(posn) {
      this.mousemove(posn);
      return delete this.clickPosn;
    };

    return Game;

  })();

  $(document).ready(function() {
    var canvas, mouseEvent, _fn, _i, _len, _ref;
    canvas = $('#the-canvas')[0];
    canvas.width = 640;
    canvas.height = 480;
    window.game = new Game(canvas);
    _ref = ['mousedown', 'mousemove', 'mouseup'];
    _fn = function(mouseEvent) {
      return $('#the-canvas')[mouseEvent](function(e) {
        var left, top, _ref1;
        _ref1 = $(this).parent().offset(), left = _ref1.left, top = _ref1.top;
        return window.game[mouseEvent](new V2(e.pageX - left, e.pageY - top));
      });
    };
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      mouseEvent = _ref[_i];
      _fn(mouseEvent);
    }
    return window.game.draw();
  });

}).call(this);
