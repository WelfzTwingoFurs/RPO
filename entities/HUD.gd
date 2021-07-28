extends CanvasLayer

onready var hud_lborder = $CanvasLayer/LBorder
onready var hud_play1 = $CanvasLayer/LBorder/Player1
onready var hud_radar = $CanvasLayer/LBorder/Radar
onready var hud_play2 = $CanvasLayer/LBorder/Player2
onready var hud_rborder = $CanvasLayer/LBorder/RBorder
onready var hud_extender = $CanvasLayer/LBorder/Extender

onready var hud_lifebar = $CanvasLayer/LBorder/Player1/Life1
onready var hud_ammo1 = $CanvasLayer/LBorder/Player1/Ammo1

var minX = 0
var maxX = 0
# These will be set in-level, exported to global, then imported to entities.
var minY = 0
var maxY = 0


func _ready():
	minX = Global.minX
	maxX = Global.maxX
	minY = Global.minY
	maxY = Global.maxY

#Radar is 113 pixels wide;
#Stats are 184, together 368;
#The borders are 6, together are 12;
#Altogether they are 493!

#if the window is smaller than that, stats will be on top of the radar.
#So, if that's the case, give up the log area

func hudconfig():
	zoom = Global.resolution
	windowX = get_viewport().size.x
	windowY = get_viewport().size.y
	screen = OS.get_screen_size()

	if windowY < minY*2:
		$Camera2D.position.y = minY - windowY

	#In 4:3, it's 640x480 at zoom 1

#########################################################################################################
	hud_rborder.position.x = screen.x/zoom

	hud_radar.position.x = (windowX / 2) -56# sprite's X divided by 2
	hud_extender.scale.x = windowX / 6#sprite's X

	hud_lborder.position.y = windowY -87 -(40/zoom)# sprite's Y & Windows 10's deskbar

	if windowX < 481:
		hud_play1.position.x = -10#(windowX / 2) /(zoom+1)
		hud_play2.position.x = (screen.x/zoom) -174# sprite's X
	elif windowX > 481 && windowX < 493:
		hud_play1.position.x = 5#(windowX / 2) /(zoom+1)
		hud_play2.position.x = (screen.x/zoom) -187# sprite's X
	else:
		hud_play1.position.x = (windowX / 2) /(zoom+1)
		hud_play2.position.x = (windowX / 2) +((windowX / 2)-(hud_play1.position.x)) -184# sprite's X
#########################################################################################################

var zoom
var screen
var windowX
var windowY

#func hudconfig():
#	zoom = Global.resolution
#	windowX = get_viewport().size.x
#	windowY = get_viewport().size.y
#	screen = OS.get_screen_size()
#
#	if windowY < minY*2:
#		$Camera2D.position.y = minY - windowY
#
#	hud_rborder.position.x = screen.x/zoom
#	hud_radar.position.x = (windowX / 2) -56#Sprite's X divided by 2
#	hud_extender.scale.x = windowX / 6#sprite's X
#
#	hud_play1.position.x = (windowX / 2) /(zoom+1)
#	hud_play2.position.x = (windowX / 2) +((windowX / 2)-(hud_play1.position.x)) -184#Sprite's X
#
#	hud_lborder.position.y = windowY -87 -(40/zoom)#Sprite's Y & Windows 10's deskbar
#
#	$Camera2D.drag_margin_top = 2/zoom
#	$Camera2D.drag_margin_bottom = 2/zoom
