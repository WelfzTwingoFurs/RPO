extends KinematicBody2D
onready var Sprite = $Sprite
onready var Shadow = $Shadow

var driver = 0
var input_dirX = 0
var input_dirY = 0

var faceX = 1
var faceY = 0

var motion_dirX
var motion_dirY

var motion = Vector2()

export var lazyWeg = 0
var aniframe = 0

var minX = 0
var maxX = 0
# These will be set in-level, exported to global, then imported to entities.
var minY = 0
var maxY = 0

func _ready():
	$AnimationPlayer.play("lazy")
	minX = Global.minX
	maxX = Global.maxX
	minY = Global.minY
	maxY = Global.maxY

var playerY

var Zindexvar = 1

func _physics_process(delta):
	if position.y > minY: #460
		position.y += minY-position.y
	elif position.y < maxY: ##246
		position.y += maxY-position.y
	
	if position.x > maxX: ##2900
		position.x += maxX-position.x
	elif position.x < minX: #0
		position.x += minX-position.x
	
	playerY = position.y - Global.player.position.y
	self.z_index = (position.y/10)-Zindexvar
	
	if abs(motion.x) > abs(motion.y):
		$AnimationPlayer.playback_speed = motion.x/100
	else:
		$AnimationPlayer.playback_speed = motion.y/50
	
	#$Label.text = str("SPEED: X=",round(motion.x)," Y=",round(motion.y),"\nFACE: X=",faceX," Y=",faceY,"\nMot-Dir: X=",motion_dirX," Y=",motion_dirY)
	$Label.text = str("")
	Shadow.frame = aniframe
	Sprite.frame = aniframe
	
	if faceX == 1:
		set_flipped(false)
	elif faceX == -1:
		set_flipped(true)
	
	if motion.x > 10:
		motion_dirX = 1
	elif motion.x < -10:
		motion_dirX = -1
	else:
		motion_dirX = 0
	
	if motion.y > 5:
		motion_dirY = 1
	elif motion.y < -5:
		motion_dirY = -1
	else:
		motion_dirY = 0
	
	
	motion = move_and_slide(motion, Vector2(0,-1))
	if driver == 1:
		if Input.is_action_pressed("ply_moveleft"):
			input_dirX = -1
		elif Input.is_action_pressed("ply_moveright"):
			input_dirX = 1
		else:
			input_dirX = 0
	
		if Input.is_action_pressed("ply_moveup"):
			input_dirY = -1
		elif Input.is_action_pressed("ply_movedown"):
			input_dirY = 1
		else:
			input_dirY = 0
	
	
	else:
		motion.x = lerp(motion.x,0,0.02)
		motion.y = lerp(motion.y,0,0.01)
		$Label.text = str("go [E]n!")
	
	## Input & motion logic ##
	
	if input_dirY == 0: 
		if faceY == 0:
			motion.y = lerp(motion.y,0,0.05) #De-accel Y when no Y inputs
		else:
			if faceX == 0:
				motion.y = lerp(motion.y,0,0.04)
			else:
				motion.y = lerp(motion.y,0,0.02)
	else:
		if faceY != 0:
			if input_dirY == faceY:
				motion.y += 2*input_dirY #Accel when speeding in facing direction
			elif motion_dirY == faceY:
				motion.y = lerp(motion.y,0,0.20) #De-accel Y when breaking
			else:
				motion.y += 0.5*input_dirY #Otherwise reversing speed
		else:
			motion.y += input_dirY*abs(motion.x)/100
			motion.y = lerp(motion.y,0,0.04)
	
	if input_dirX == 0:
		if faceX == 0:
			motion.x = lerp(motion.x,0,0.10) #De-accel X when no X inputs
		else:
			if faceY == 0:
				motion.x = lerp(motion.x,0,0.02)
			else:
				motion.x = lerp(motion.x,0,0.01)
	else:
		if faceX != 0:
			if input_dirX == faceX:
				motion.x += 4*input_dirX #Accel when speeding in facing direction
			elif motion_dirX == faceX:
				motion.x = lerp(motion.x,0,0.10) #De-accel X when breaking
			else:
				motion.x += input_dirX  #Otherwise reversing speed
		else:
			motion.x += input_dirX*abs(motion.y)/50
			motion.x = lerp(motion.x,0,0.02)
	
	
	## Facing direction logic ##
	
	if abs(faceX) == 1:
		if abs(motion.y) > 50: #Speed Y to side>>diagonal
			if faceX == motion_dirX:
				if faceY != -motion_dirY:
					if motion.y > 0:
						faceY = 1
					else:
						faceY = -1
				else:
					faceY = 0
				
			else: #BACKWARDS side>>diagonal
				if faceY != motion_dirY:
					if motion.y > 0:
						faceY = -1
					else:
						faceY = 1
				#elif faceY == -motion_dirY:
				#	faceY = 0
				else:
					pass
			
			
		else:
			if abs(motion.x) > 250: #Speed X to diagonal>>side
				faceY = 0
	
	if abs(faceY) == 1:
		if abs(motion.x) > 75: #Speed X to top/down>>diagonal
			if faceY == motion_dirY:
				if faceX != -motion_dirX:
					if motion.x > 0:
						faceX = 1
					else:
						faceX = -1
				else:
					faceX = 0
					
			else: #BACKWARDS side>>diagonal
				if faceX != motion_dirX:
					if motion.x > 0:
						faceX = -1
					else:
						faceX = 1
				else:
					pass
		else:
			if abs(motion.y) > 125: #Speed Y to diagonal>>top/down
				faceX = 0
	
	
	
	if faceX != 0:
#		if input_dirX == faceX: #Facing forward
		if motion_dirX == faceX: #Facing forward
			if faceY == 1: #Going right and up
				aniframe = (1 + lazyWeg) #diag-down
			elif faceY == -1: #Going right and down
				aniframe = (4 + lazyWeg)#diag-up
			else: #Just going right
				aniframe = (0 + lazyWeg)

#		elif input_dirX != faceX:
		elif motion_dirX != faceX:
			if faceY == 1: #Going left and up
				aniframe = (1 + lazyWeg)#diag-down
			elif faceY == -1: #Going left and down
				aniframe = (4 + lazyWeg)#diag-up
			else: #Just going right
				aniframe = (0 + lazyWeg)
	
	else:
		if faceY == 1:
			aniframe = 2 + (lazyWeg)#down
		else:
			aniframe = 3 + (lazyWeg)#up
	
	
	
	
	
	
	
	
	for body in driversarray:
		if driver == 0:
			if Input.is_action_just_pressed("ply_interact"):
				Zindexvar = -1
				body.driving()
				driver = 1
		else:
			body.car = self
			if Input.is_action_just_pressed("ply_interact"):
				Zindexvar = 1
				body.idle()
				driver = 0
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


var driversarray = []

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		body.car = self
		if !driversarray.has(body):
			driversarray.push_back(body)
	else:
		if abs(motion.x) > 100:
			if body.is_in_group("enemy"):
				body.take_damage(1)


func _on_Area2D_body_exited(body):
	if driversarray.has(body):
		driversarray.erase(body)

func set_flipped(flipstate):
	if flipstate: ### LEFT ###
		Sprite.flip_h = true
		Shadow.flip_h = true
	else: ########### RIGHT ###
		Sprite.flip_h = false
		Shadow.flip_h = false
