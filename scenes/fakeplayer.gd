extends Position2D

func _ready():
	Global.playerX = position.x
	Global.playerY = position.y
	Global.player = self

func hudconfig():
	pass
