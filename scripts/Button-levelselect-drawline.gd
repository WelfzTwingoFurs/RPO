extends Node2D
var camera = Vector2(0,0)

func _draw():
	draw_line(Vector2(250,199), camera, Color(0, 0, 1), 1)

func _process(delta):
	camera = Global.player.global_position - position
	update()
