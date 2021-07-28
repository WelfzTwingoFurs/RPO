extends Node2D

export var minX = 0
export var maxX = 0
export var minY = 0
export var maxY = 0

func _process(delta):
	Global.minX = minX
	Global.maxX = maxX
	Global.minY = minY
	Global.maxY = maxY
	
	print(Global.minX,Global.minY,Global.maxX,Global.maxY)
