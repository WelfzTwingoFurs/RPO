extends KinematicBody2D

var radar_icon = "car"

onready var Sprite = $Sprite
onready var Shadow = $Sprite/Shadow
onready var Interior = $Sprite/Interior
onready var Col2D = $Area2Dsolid/Col2D
onready var Driver = $Driver
onready var Audio = $Audio
onready var Audio2 = $Audio2

onready var bullshit2D = $Area2Dsolid

var driver = 0
var input_dirX = 0
var input_dirY = 0

export var faceX = 1
export var faceY = 0

var motion_dirX
var motion_dirY

var motion = Vector2()

export var lazyWeg = 0
var turnframe = 0
var aniframe = 0

export var minX = 0
export var maxX = 0
# These will be set on startup, and re-adjusted by RayCast2D's in the levels
export var minY = 0
export var maxY = 0

var our_colX = 0
var our_colY = 0

enum STATES {EMPTY,PLAYER,ENEMY}
export(int) var state = STATES.EMPTY

func _ready():
	$AnimationPlayer.play("lazy")
	Driver.visible = 0
	
	bullshit2D.minX = minX
	bullshit2D.maxX = maxX
	bullshit2D.minY = minY
	bullshit2D.maxY = maxY


var Zindexvar = -1

var ourCol

#func _process(delta): # CHANGE IT TO PHYSICS PROCESS YOU DUMBASS
func _physics_process(delta):
	minX = bullshit2D.minX
	maxX = bullshit2D.maxX
	minY = bullshit2D.minY
	maxY = bullshit2D.maxY
	bullshit2D.motion_dirX = motion_dirX
	
	#print(motion_dirX)
	
	match state:
		STATES.EMPTY:
			emptyinside()
		STATES.PLAYER:
			playerdrive()
		STATES.ENEMY:
			enemydrive()
	
	
	
	if position.y > minY: #460
		position.y += minY-position.y
	elif position.y < maxY: ##246
		position.y += maxY-position.y
	
	if driver != 0:
		if position.x > maxX: ##2900
			position.x += maxX-position.x
		elif position.x < minX: #0
			position.x += minX-position.x
	

	self.z_index = (position.y/10)+Zindexvar
	
	if abs(motion.x) > abs(motion.y):
		$AnimationPlayer.playback_speed = motion.x/100
		Audio.pitch_scale = abs(motion.x-(motion.x/3))/200 +0.1
		
		if state != 0:
			Audio.car_engine()
			if input_dirX != faceX && faceX == motion_dirX && input_dirX != 0:
				Audio2.car_tire()
		
		
	else:
		$AnimationPlayer.playback_speed = motion.y/50
		Audio.pitch_scale = abs(motion.y-(motion.y/3))/200 +0.1
		
		if state != 0:
			Audio.car_engine()
			if input_dirY != faceY && faceY == motion_dirY && input_dirY != 0:
				Audio2.car_tire()






	Shadow.frame = aniframe
	Sprite.frame = aniframe
#	Interior.frame = 30 + aniframe
	
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
	
	
	var damnCol = (Col2D.get_shape().get_extents())
	ourCol = Vector2( round(damnCol.x*Col2D.scale.x),round(damnCol.y*Col2D.scale.y) )
	
	# Our col Y is normally 18, but we use 4 and 25.
	# 18/4 is 4,5, 18*1,4 is 25,2
	
	
#	$Label.text = str((Col2D.get_shape().get_extents()),"\n~",Col2D.scale,"\n=",ourCol,"\n\n",
#	round(playerX)," ",round(playerY),"\n",round(pedX)," ",round(pedY))
	
	#$Label.text = str(round(playerX)," ",round(playerY),"\n",round(pedX)," ",round(pedY))
	
	#COLLIDE LOGIC
	#only the player goes into driversarray. enemies will do into another
	
	# "for body in driversarray" moved to _process
	
	for body in pedsarray:
		if pedsarray != null:
			pedX = round(position.x - body.position.x)
			pedY = round(position.y - body.position.y)
			
			if abs(motion.x) > 100:
				body.take_damage(1)
				Audio2.car_ouch()
				if driver != 0:
					Global.player.score += 5
				else:
					if takeoff != 0:
						Global.player.score += 20
			if abs(motion.y) > 50:
				body.take_damage(1)
				Audio2.car_ouch()
				if driver != 0:
					Global.player.score += 5
				else:
					if takeoff != 0:
						Global.player.score += 10
			
			
			
			if pedY > 5 && pedY < 24:
				if pedX > ourCol.x:
					body.blockX = 1
				elif pedX < -ourCol.x:
					body.blockX = -1
			else:
#				body.blockX = 0
				
				if pedY < 14:
					if pedY > 4:
						body.blockY = -1
					elif pedY < 4:
						body.blockY = 0
				
				else:
					if pedY < 25:
						body.blockY = 1
					elif pedY > 25:
						body.blockY = 0
		
		
	
	
	if state != 2:
		if driversarray == null:
			change_state(STATES.EMPTY)
	
	
	
	
	
	############################################################################################
	## Facing direction logic ##
	
	if abs(faceX) == 1:
		if abs(motion.y) > 50: #Speed Y to side>>diagonal
			if faceX == motion_dirX:
				if faceY != -motion_dirY:
					if motion.y > 0:
						if faceY != -1:
							faceY = 1
						else:
							faceY = 0
					else:
						if faceY != 1:
							faceY = -1
						else:
							faceY = 0
				else:
					faceY = 0
				
			else: #BACKWARDS side>>diagonal
				if faceY != motion_dirY:
					if motion.y > 0:
						if faceY != 1:
							faceY = -1
						else:
							faceY = 0
					else:
						if faceY != -1:
							faceY = 1
						else:
							faceY = 0
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
						if faceX != -1:
							faceX = 1
						else:
							faceX = 0
					else:
						if faceX != 1:
							faceX = -1
						else:
							faceX = 0
				else:
					faceX = 0
					
			else: #BACKWARDS side>>diagonal
				if faceX != motion_dirX:
					if motion.x > 0:
						if faceX != 1:
							faceX = -1
						else:
							faceX = 0
					else:
						if faceX != -1:
							faceX = 1
						else:
							faceX = 0
				else:
					pass
		else:
			if abs(motion.y) > 125: #Speed Y to diagonal>>top/down
				faceX = 0
	
	
	#Redundancy, but fix later, since this is easier to read
	if faceX != 0:
		if motion_dirX == faceX: #Facing forward
			if faceY == 1: #Going right and up
				aniframe = (1 + lazyWeg + turnframe) #diag-down
				Interior.frame = 31
			elif faceY == -1: #Going right and down
				aniframe = (2 + lazyWeg + turnframe)#diag-up
				Interior.frame = 32
			else: #Just going right
				aniframe = (0 + lazyWeg + turnframe)
				Interior.frame = 30

		elif motion_dirX != faceX:
			if faceY == 1: #Going left and up
				aniframe = (1 + lazyWeg + turnframe)#diag-down
				Interior.frame = 31
			elif faceY == -1: #Going left and down
				aniframe = (2 + lazyWeg + turnframe)#diag-up
				Interior.frame = 32
			else: #Just going right
				aniframe = (0 + lazyWeg + turnframe)
				Interior.frame = 30
		
		
		# Collision sizing #
		if faceY != 0:
			Col2D.scale.x = 0.6#0.75
			Col2D.scale.y = 1.5
			Col2D.position.x = 0
			Col2D.position.y = 13
			Sprite.position.y = 0
			
			if state != 0:
				Col2D.position.x = 15 * (faceX/faceY)
				Col2D.position.y = 13
				Col2D.scale.x = 0.65
				Sprite.position.y = 0
			else:
				Col2D.scale.x = 0.75
				Col2D.position.x = 0
				Col2D.position.y = 13
				Sprite.position.y = 0
			
		else:
			Col2D.scale.x = 1
			Col2D.scale.y = 1
			Col2D.position.x = 0
			Col2D.position.y = 13
			Sprite.position.y = 0
			
	else:
		Col2D.scale.x = 0.5
		Col2D.scale.y = 1.75
		Col2D.position.y = 13
		Col2D.position.x = 0
		Sprite.position.y = -13
		
	
		
		if faceY == 1:
			aniframe = 3 + (lazyWeg + turnframe)#down
			Interior.frame = 33
		else:
			Sprite.flip_h = false
			aniframe = 4 + (lazyWeg + turnframe)#up
			Interior.frame = 34










	motion = move_and_slide(motion, Vector2(0,-1))
#func _physics_process(delta):
#	motion = move_and_slide(motion, Vector2(0,-1))
	motion.x = lerp(motion.x,0,0.02)
	motion.y = lerp(motion.y,0,0.01)

func _process(delta):
	for body in driversarray:
#		if body.get_name() != "GroundCol":
		if body.state != 2: # if PLAYER's isn't 2, which for it, is DRIVING.
			playerX = round(position.x - body.position.x)
			playerY = round(position.y - body.position.y)
			
			
			if takeoff == 0 && driver == 0 && body.positionZ == 0:
				if abs(motion.x) > 100:
					if sign(playerX) == -motion_dirX:
						if abs(playerY) < 30:
							body.motion.x = motion.x
							body.health = 0
							body.die()
					
				if abs(motion.y) > 50:
					if sign(playerY) == -motion_dirY:
						if abs(playerY) < 30:
							body.motion.y = motion.y
							body.health = 0
							body.die()
		
		var colYtop = ourCol.y + 10
		
		if body.positionZ == 0:
			if playerY > 5 && playerY < colYtop:
				if playerX > ourCol.x:
					body.position.x = lerp(body.position.x,body.position.x-position.x,0.000005)
					body.blockX = 1
				elif playerX < -ourCol.x:
					body.position.x = lerp(body.position.x,body.position.x+position.x,0.000005)
					body.blockX = -1
			else:
				body.blockX = 0
				
				if playerY < 14:
					if playerY > 4:
						body.position.y = lerp(body.position.y,body.position.y+position.y,0.0005)
						body.blockY = -1
					elif playerY < 4:
						body.blockY = 0
				
				else:
					if playerY < colYtop +1:
						body.position.y = lerp(body.position.y,body.position.y-position.y,0.0005)
						body.blockY = 1
					elif playerY > colYtop +1:
						body.blockY = 0
			
			
		else:
			if playerY > 5 && playerY < colYtop:
				body.blockY = 0
				body.blockX = 0
				if body.motionZ >= 0:
					
					if playerY > 14:
						body.position.y -= 1
					elif playerY < 14:
						body.position.y += 1
						
#						body.blockZ = 1
#				else:
#					body.blockZ = 0
		
		
		if state != 2:
			if body.car != self:
				change_state(STATES.EMPTY)
			if body.state != 2:
				change_state(STATES.EMPTY)
		
		if driver == 0:
			if Input.is_action_just_pressed("ply_interact"):
				if abs(playerY) < 45 && body.positionZ == 0:
					takeoff = 1
					Interior.z_index = -2
					Zindexvar = 1
					driver = 1
					body.driving()
					
					if state == 2:
						shootman()
					
					change_state(STATES.PLAYER)
		else:
			if Input.is_action_just_pressed("ply_interact"):
				if abs(playerY) < 45 && body.positionZ == 0:
					takeoff = 1
					Interior.z_index = 0
					Zindexvar = -1
					driver = 0
					body.idle()
					
					body.position.x += body.drivepos.x
					body.Shadow.visible = 1
					body.Sprite.position = Vector2(0,0)
					
					change_state(STATES.EMPTY)

func change_state(new_state):
	state = new_state
	Driver.visible = 0

var takeoff = 0

func emptyinside():
#	$Label.text = str(round(playerX)," ",round(playerY),"\n",round(pedX)," ",round(pedY))
#	$Label.text = str(motion.x," ",motion.y," ",takeoff)
	
#	if abs(motion.x) < 1:
#		takeoff = 0
#	if abs(motion.y) < 1:
#		takeoff = 0
	
	for body in driversarray:
		if body.car == self:
			body.idle()
			Sprite.position = Vector2(0,0)



func playerdrive():
#	$Label.text = str("SPEED: X=",round(motion.x)," Y=",round(motion.y),"\nFACE: X=",faceX," Y=",faceY,
#	"\nMot-Dir: X=",motion_dirX," Y=",motion_dirY,"\nAniframe:",aniframe)
	
	if driver == 0:
		change_state(STATES.EMPTY)
	else:
		takeoff = 1
	
	if Input.is_action_pressed("ply_moveleft"):
		input_dirX = -1
		
		if faceY == 0: #Wheels when no Y
			if input_dirY == 1:
				turnframe = 20
			elif input_dirY == -1:
				turnframe = 10
			else:
				turnframe = 0
		else:
			if abs(input_dirY) == 1:
				if input_dirX == faceX:
					if input_dirY == faceY:
						turnframe = 0
					else:
						if faceY == -1:
							turnframe = 20
						else:
							turnframe = 10
				else:
					if motion_dirX != faceX:
						turnframe = 0
					else:
						if faceY == -1:
							turnframe = 10
						else:
							turnframe = 20
			else:
				if faceY == 1:
					if faceX == 1:
						turnframe = 20
					else:
						turnframe = 10
				else:
					if faceX == 1:
						turnframe = 10
					else:
						turnframe = 20
		
		
	elif Input.is_action_pressed("ply_moveright"):
		input_dirX = 1
		
		if faceY == 0: #Wheels when no Y
			if input_dirY == 1:
				turnframe = 20
			elif input_dirY == -1:
				turnframe = 10
			else:
				turnframe = 0
		else:
			if abs(input_dirY) == 1:
				if input_dirX == faceX:
					if input_dirY == faceY:
						turnframe = 0
					else:
						if faceY == -1:
							turnframe = 20
						else:
							turnframe = 10
				else:
					if motion_dirX != faceX:
						turnframe = 0
					else:
						if faceY == -1:
							turnframe = 10
						else:
							turnframe = 20
			else:
				if faceY == 1:
					if faceX == 1:
						turnframe = 10
					else:
						turnframe = 20
				else:
					if faceX == 1:
						turnframe = 20
					else:
						turnframe = 10
		
		
	else:
		input_dirX = 0

	if Input.is_action_pressed("ply_moveup"):
		input_dirY = -1
		
		if faceX == 0: #Wheels when no X
			set_flipped(false)
			if input_dirX == 1:
				if faceY == 1:
					turnframe = 20
				else:
					turnframe = 10
			elif input_dirX == -1:
				if faceY == 1:
					turnframe = 10
				else:
					turnframe = 20
			else:
				turnframe = 0
		else:
			if input_dirX == 0:
				turnframe = 10
		
	elif Input.is_action_pressed("ply_movedown"):
		input_dirY = 1
		
		if faceX == 0: #Wheels when no X
			set_flipped(false)
			if input_dirX == 1:
				if faceY == 1:
					turnframe = 10
				else:
					turnframe = 20
			elif input_dirX == -1:
				if faceY == 1:
					turnframe = 20
				else:
					turnframe = 10
			else:
				turnframe = 0
		else:
			if input_dirX == 0:
				turnframe = 20
		
	else:
		input_dirY = 0
	
	
	## Input & motion logic ##
	if input_dirY == 0: 
		if faceY == 0:
			motion.y = lerp(motion.y,0,0.005) #De-accel Y when no Y inputs
		else:
			if faceX == 0:
				motion.y = lerp(motion.y,0,0.004)
			else:
				motion.y = lerp(motion.y,0,0.002)
	else:
		if faceY != 0:
			if input_dirY == faceY:
				motion.y += (0.375*input_dirY)*8 #Accel when speeding in facing direction
			elif motion_dirY == faceY:
				motion.y = lerp(motion.y,0,0.020) #De-accel Y when breaking
			else:
				motion.y += (0.26*input_dirY)*8 #Otherwise reversing speed
		else:
			motion.y += (input_dirY*abs(motion.x)/1000)*8
			motion.y = lerp(motion.y,0,0.004)
	
	if input_dirX == 0:
		if faceX == 0:
			motion.x = lerp(motion.x,0,0.010) #De-accel X when no X inputs
		else:
			if faceY == 0:
				motion.x = lerp(motion.x,0,0.002)
			else:
				motion.x = lerp(motion.x,0,0.001)
	else:
		if faceX != 0:
			if input_dirX == faceX:
				motion.x += (input_dirX)*8 #Accel when speeding in facing direction
			elif motion_dirX == faceX:
				motion.x = lerp(motion.x,0,0.010) #De-accel X when breaking
			else:
				motion.x += (0.6*input_dirX)*8  #Otherwise reversing speed
		else:
			motion.x += (input_dirX*abs(motion.y)/500)*8
			motion.x = lerp(motion.x,0,0.002)


var drivepos = Vector2(0,0)
var driveface = 0

var playerX = 0
var playerY = 0

var pedX = 0
var pedY = 0


var system_msecs = 0
var was_secs = 0

func enemydrive():
#	system_msecs = OS.get_system_time_secs()
#	if was_secs != system_msecs: #every other seconds
	playerX = position.x - Global.playerX
	playerY = position.y - Global.playerY
		
#		was_secs = system_msecs
	
	Interior.z_index = -1
	
	if playerX > 250: #Going left
		input_dirX = -1
		
		if faceY == 0: #Wheels when no Y
			if input_dirY == 1:
				turnframe = 20
			elif input_dirY == -1:
				turnframe = 10
			else:
				turnframe = 0
		else:
			if abs(input_dirY) == 1:
				turnframe = 0
			else:
				if faceY == 1:
					if faceX == 1:
						turnframe = 20
					else:
						turnframe = 10
				else:
					if faceX == 1:
						turnframe = 10
					else:
						turnframe = 20
		
		
	elif playerX < -250: #Going right
		input_dirX = 1
		
		if faceY == 0: #Wheels when no Y
			if input_dirY == 1:
				turnframe = 20
			elif input_dirY == -1:
				turnframe = 10
			else:
				turnframe = 0
		else:
			if abs(input_dirY) == 1:
				turnframe = 0
			else:
				if faceY == 1:
					if faceX == 1:
						turnframe = 10
					else:
						turnframe = 20
				else:
					if faceX == 1:
						turnframe = 20
					else:
						turnframe = 10
		
		
	else:
		if abs(motion.x) > 100:
			input_dirX = -faceX
		else:
			input_dirX = 0

	if playerY > 50: #Going up
		input_dirY = -1
		
		if faceX == 0: #Wheels when no X
			set_flipped(false)
			if input_dirX == 1:
				if faceY == 1:
					turnframe = 20
				else:
					turnframe = 10
			elif input_dirX == -1:
				if faceY == 1:
					turnframe = 10
				else:
					turnframe = 20
			else:
				turnframe = 0
		else:
			if input_dirX == 0:
				turnframe = 10
		
	elif playerY < -50: #Going down
		input_dirY = 1
		
		if faceX == 0: #Wheels when no X
			set_flipped(false)
			if input_dirX == 1:
				if faceY == 1:
					turnframe = 10
				else:
					turnframe = 20
			elif input_dirX == -1:
				if faceY == 1:
					turnframe = 20
				else:
					turnframe = 10
			else:
				turnframe = 0
		else:
			if input_dirX == 0:
				turnframe = 20
		
	else:
		if abs(motion.y) > 50:
			input_dirY = -faceY
		else:
			input_dirY = 0


	## Input & motion logic ##
	if input_dirY == 0: 
		if faceY == 0:
			motion.y = lerp(motion.y,0,0.005) #De-accel Y when no Y inputs
		else:
			if faceX == 0:
				motion.y = lerp(motion.y,0,0.004)
			else:
				motion.y = lerp(motion.y,0,0.002)
	else:
		if faceY != 0:
			if input_dirY == faceY:
				motion.y += (0.375*input_dirY)*8 #Accel when speeding in facing direction
			elif motion_dirY == faceY:
				motion.y = lerp(motion.y,0,0.020) #De-accel Y when breaking
			else:
				motion.y += (0.26*input_dirY)*8 #Otherwise reversing speed
		else:
			motion.y += (input_dirY*abs(motion.x)/1000)*8
			motion.y = lerp(motion.y,0,0.004)

	if input_dirX == 0:
		if faceX == 0:
			motion.x = lerp(motion.x,0,0.010) #De-accel X when no X inputs
		else:
			if faceY == 0:
				motion.x = lerp(motion.x,0,0.002)
			else:
				motion.x = lerp(motion.x,0,0.001)
	else:
		if faceX != 0:
			if input_dirX == faceX:
				motion.x += (input_dirX)*8 #Accel when speeding in facing direction
			elif motion_dirX == faceX:
				motion.x = lerp(motion.x,0,0.010) #De-accel X when breaking
			else:
				motion.x += (0.6*input_dirX)*8  #Otherwise reversing speed
		else:
			motion.x += (input_dirX*abs(motion.y)/500)*8
			motion.x = lerp(motion.x,0,0.002)

	if abs(motion.x) < 90 && abs(motion.y) < 45:
		if abs(playerX) < 400:
			Driver.scale = Vector2(0,0)
			shootman()


	
	# Driver's sprite logic
	Driver.visible = 1
	Driver.position = drivepos
	Driver.scale.x = driveface
	
	if faceX != 0:
		driveface = faceX
		
		if faceY == 0:
			Driver.frame = 70 # -> sideways
			if faceX == 1:
				drivepos = Vector2(-6,-50)
			else:
				drivepos = Vector2(7,-49)
		else:
			if faceY == -1:
				Driver.frame = 72 # ¨| diag-up
				if faceX == 1:
					drivepos = Vector2(-7,-55)
				else:
					drivepos = Vector2(-31,-53)
			if faceY == 1:
				Driver.frame = 71 # _| diag-down
				if faceX == 1:
					drivepos = Vector2(-1,-55)
				else:
					drivepos = Vector2(25,-54)
		
	else:
		driveface = 1
		if faceY == 1:
			Driver.frame = 73 # \/ down
			drivepos = Vector2(14,-63)
		else:
			Driver.frame = 74 # /\ up
			drivepos = Vector2(-19,-60)

const DORTOR = preload("res://entities/dortor.tscn")

func shootman():
	var bul_instance = DORTOR.instance()
	bul_instance.scale = self.scale
	bul_instance.position = Vector2(position.x,position.y)
	get_parent().add_child(bul_instance)
	
	bul_instance.minX = minX
	bul_instance.maxX = maxX
	bul_instance.minY = minY
	bul_instance.maxY = maxY
	
	Driver.visible = 0
	change_state(STATES.EMPTY)




#COLLIDE LOGIC
var driversarray = []
var pedsarray =[]

#for i in get_slide_count():
#    var collision = get_slide_collision(i)
#    print(collision.collider.name)

func _on_Area2D_body_entered(body):
#	if body.get_name() != "GroundCol":
	if body.is_in_group("player"):
		
		$Label.text = str("[E]")
		
		if !driversarray.has(body):
			driversarray.push_back(body)
		if body.state != 2:
			body.car = self
			
	elif body.is_in_group("enemy"):
		if !pedsarray.has(body):
			pedsarray.push_back(body)
		
#		if abs(motion.x) > 100:
#			body.take_damage(1)
#		if abs(motion.y) > 50:
#			body.take_damage(1)


func _on_Area2D_body_exited(body):
	if body.is_in_group("player"):
		body.blockX = 0
		body.blockY = 0
#		body.blockZ = 0
		$Label.text = str("")
		
		takeoff = 0
	
		if driversarray.has(body):
			driversarray.erase(body)
			if driver != 0:
				driver = 0
	
	elif body.is_in_group("enemy"):
		body.blockX = 0
		body.blockY = 0
		
		if pedsarray.has(body):
			pedsarray.erase(body)



func set_flipped(flipstate):
	if flipstate: ### LEFT ###
		Sprite.flip_h = true
		Shadow.flip_h = true
		Interior.flip_h = true
	else: ########### RIGHT ###
		Sprite.flip_h = false
		Shadow.flip_h = false
		Interior.flip_h = false


#var carsarray = []

#export var crashmotion = Vector2(0,0)

func _on_Area2Dsolid_area_entered(area):
#	crashmotion = motion
	
	if area.get_name() == "Area2Dsolid":
#		$Label.text = str(sign(area.global_transform.origin.x - position.x))
#		print("their shit:",area.crashmotion)
		
		#area.position.y
		
		motion.x = -sign(area.global_transform.origin.x - position.x)*abs(motion.x-(motion.x/3)+20/2)
		motion.y = -sign(area.global_transform.origin.y - position.y)*abs(motion.y-(motion.y/3)+10/2)
		
		Audio2.car_ouch()


#func _on_Area2Dsolid_area_exited(area):
#	if area.get_name() == "Area2Dsolid":
#		if carsarray.has(area):
#			carsarray.erase(area)
