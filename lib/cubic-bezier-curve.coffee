$ = jQuery = require("atom").$
jqueryui = require("../jquery-ui.js")
CB = {}
CB.showCubicBezier = showCubicBezier = ->
  canvas = document.getElementById("cubic-bezier")
  CB.context = canvas.getContext("2d")
  drawInitialCurve()
  $("#P0, #P1").draggable
    containment: "#cubic-bezier"
    scroll: false
    drag: drag
    stop: drag
    cancel: false
    stack: ".curve-pointer"

  plotCurve()
  return

CB.drag = drag = (e) ->
  pos = $(this).position()
  top = pos.top
  left = pos.left
  data = $(this).data()
  $(this).data "x", left
  $(this).data "y", top
  plotCurve e
  playBall()
  return

CB.drawInitialCurve = ->
  drawPoints coordinatesToPoints(
    top: 0.31
    left: 0.74
  ,
    top: 0.80
    left: 0.37
  , $("#cubic-bezier"))
  return

CB.coordinatesToPoints = (p0, p1, $$) ->
  canvasGraph = document.getElementById("cubic-bezier")
  w = canvasGraph.width
  h = canvasGraph.height
  throw "height=" + h + "width=" + w + " is not greater than width"  if h < w

  # Extra space for Y-axis
  adj = (h - w) / 2
  parent = $$.parent()
  pdh = parent.outerHeight(true) - parent.innerHeight()
  pdw = parent.outerWidth(true) - parent.innerWidth()
  gw = w - pdw
  gh = h - pdh

  #if (p0.left > 1 || p0.left < 0  || p1.left > 1 || p1.left < 0) throw "x axis should be in a range [0,1]";
  x1 = parseInt(p0.left * gw)
  x2 = parseInt(p1.left * gw)
  y1 = parseInt((if (p0.top > 1) then (1 - p0.top) * w + adj else ((if (p0.top < 0) then (Math.abs(p0.top) * w) + w + adj else (w - p0.top * w) + adj))))
  y2 = parseInt((if (p1.top > 1) then (1 - p1.top) * w + adj else ((if (p1.top < 0) then (Math.abs(p1.top) * w) + w + adj else (w - p1.top * w) + adj))))
  [
    x1
    y1
    x2
    y2
  ]

CB.timeDelay = (e) ->
  CB.context.font = "14px times"
  CB.context.fillStyle = "rgba(0, 0, 0, 0.4)"
  mx = e and (e.offsetX or e.clientX - $(e.target).offset().left)
  my = e and (e.offsetY or e.clientY - $(e.target).offset().top)
  w = CB.context.canvas.width
  h = CB.context.canvas.height
  adj = (h - w) / 2
  if not e or e.type isnt "mousemove" or not mx or not my
    CB.context.fillText "DURATION", w / 3.5, w + adj + 30
    CB.context.fillText "TRANSITION", w / 3.5, adj - 10
  else
    ah = h - 2.0 * adj
    parent = $("#cubic-bezier").parent()
    pdh = parent.outerHeight(true) - parent.innerHeight()
    transition = parseInt((+(((ah - (my - pdh - adj)) / ah).toFixed(2))) * 100)
    delay = parseInt(Math.ceil(mx / w * 100))
    CB.context.fillText "DURATION(" + delay + "%)", w / 3.5, w + adj + 30
    CB.context.fillText "TRANSITION(" + transition + "%)", w / 3.5, adj - 10
  delay

CB.drawPoints = (points) ->
  throw "Invalid points: " + points  if not points or points.length isnt 4
  $("#P0").css "top", points[1]
  $("#P0").css "left", points[0]
  $("#P1").css "top", points[3]
  $("#P1").css "left", points[2]
  $("#P0").data "x", points[0]
  $("#P0").data "y", points[1]
  $("#P1").data "x", points[2]
  $("#P1").data "y", points[3]
  return

CB.validateBezierPoint = validateBezierPoint = (p) ->
  return true  if p and p.x >= 0 and p.x <= 1 and p.y < 2 and p.y > -2
  false

CB.initPlot = initPlot = (w, p) ->

  #reset screen
  CB.context.canvas.width = CB.context.canvas.width
  CB.context.fillStyle = "rgba(0, 0, 0, 0.025)"
  ticks = w / 10
  y = w + p - ticks
  x = w / ticks - 1

  while y >= p
    if x is 5
      CB.context.fillStyle = "rgba(55, 80, 190, 0.25)"
    else
      CB.context.fillStyle = "rgba(100, 90, 90, 0.1)"
    CB.context.fillRect 0.5, y, w, 1
    CB.context.fillRect x * ticks - 0.5, p, 1, w
    y -= ticks
    x -= 1
  CB.context.fillRect w - 0.5, p, 1, w
  CB.context.moveTo 0, p
  CB.context.lineTo 0, w + p
  CB.context.lineTo w + p, w + p
  CB.context.lineWidth = 2
  CB.context.strokeStyle = "rgba(0, 0, 0, 0.4)"
  CB.context.stroke()
  CB.context.fillStyle = "rgba(255,0,202,0.055)"
  CB.context.beginPath()
  fph = $("#FP0").height() - 2
  fpw = $("#FP0").width() - 2
  CB.context.moveTo 0, w + p - (fpw + fph - 5)
  CB.context.lineTo w + p - (fpw + fph - 5), 0
  CB.context.lineTo w + p, Math.abs(fph - fpw)
  CB.context.lineTo Math.abs(fph - fpw), w + p
  CB.context.closePath()
  CB.context.fill()
  return

CB.plotCurve = plotCurve = (e) ->

  # coordinates
  p0 = $("#P0").data()
  p1 = $("#P1").data()
  w = $("#cubic-bezier").width()
  h = $("#cubic-bezier").height()
  throw "height is not greater than width"  if h < w

  # Extra space for Y-axis
  adj = (h - w) / 2
  parent = $("#cubic-bezier").parent()
  pdh = parent.outerHeight(true) - parent.innerHeight()
  pdw = parent.outerWidth(true) - parent.innerWidth()

  # draw plot
  initPlot w, adj
  ah = h - 2.0 * adj
  x1 = +((((p0.x - pdw) * 1.0) / w).toFixed(2))
  y1 = +(((ah - (p0.y - pdh - adj)) / ah).toFixed(2))
  x2 = +(((p1.x - pdw) * 1.0 / w).toFixed(2))
  y2 = +(((ah - (p1.y - pdh - adj)) / ah).toFixed(2))
  $(".cb-x1").text x1
  $(".cb-x2").text x2
  $(".cb-y1").text y1
  $(".cb-y2").text y2
  fph = $("#FP0").height() - 2
  fpw = $("#FP0").width() - 2

  # tracking lines
  CB.context.beginPath()
  CB.context.moveTo 0, w + adj
  CB.context.lineTo p0.x - pdw, p0.y - pdh
  CB.context.closePath()
  CB.context.lineWidth = 5
  CB.context.strokeStyle = "deepskyblue"
  CB.context.stroke()
  CB.context.beginPath()
  CB.context.moveTo w, adj
  CB.context.lineTo p1.x - pdw, p1.y - pdh
  CB.context.closePath()
  CB.context.lineWidth = 5
  CB.context.strokeStyle = "rgba(50, 205, 149, 0.86)"
  CB.context.stroke()

  # bezier curve
  CB.context.beginPath()
  CB.context.moveTo 0, w + adj
  CB.context.bezierCurveTo p0.x - pdw, p0.y - pdh, p1.x - pdw, p1.y - pdh, w, adj
  CB.context.lineWidth = 5
  CB.context.strokeStyle = "deeppink"
  CB.context.stroke()
  CB.points = [
    x1
    y1
    x2
    y2
  ]
  timeDelay e
  return

CB.playBall = ->
  playingAnimation = true

  #$('#playBall').css('transition','all 1.0s cubic-bezier('+points[0]+','+points[1]+','+points[2]+','+points[3]+')');
  $("#playBall").css "transition-timing-function", "cubic-bezier(" + points[0] + "," + points[1] + "," + points[2] + "," + points[3] + ")"
  $("#playBall").css "transition-duration", "1.0s"
  $("#playBall").css "position", "relative"
  $("#playBall").css "left", "100%"
  return

exports.showCubicBezier = CB.showCubicBezier
