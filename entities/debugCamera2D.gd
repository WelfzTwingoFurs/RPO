extends Camera2D

export var speed = 3.8

func _ready():
	Engine.time_scale = speed

func _physics_process(delta):
	
	if !Input.is_action_pressed("ply_jump"):
		
		if Input.is_action_pressed("ply_moveright"):
			position.x += 10
		elif Input.is_action_pressed("ply_moveleft"):
			position.x -= 10

		if Input.is_action_pressed("ply_movedown"):
			position.y += 10
		elif Input.is_action_pressed("ply_moveup"):
			position.y -= 10
