extends KinematicBody2D

var motion = Vector2()
var speed = 100

onready var Sprite = $Sprite
onready var Shadow = $Shadow
onready var AniPlay = $AnimationPlayer
onready var Col2D = $Col2D

enum STATES {IDLE,DOORSPAWN}
export(int) var state = STATES.IDLE


var minX = 0
var maxX = 973
# These will be set in-level, exported to global, then imported to entities.
var minY = 350
var maxY = 246

var type 

var faketimer = 0
var timerstep = 1
var timervalues = [11,22,43,44,45,66,67,68,69]

const BUL_ENTITY = preload("res://entities/bullet.tscn")

const alt1 = preload("res://media/recruto1.png")
const alt2 = preload("res://media/recruto5.png")
const alt3 = preload("res://media/recruto7.png")

func change_state(new_state):
	state = new_state

func _ready():
	Global.foes += 1
	
	howmany = Global.foes
	
	if howmany < 1:
		howmany = 1
	
	minX = Global.minX
	maxX = Global.maxX
	minY = Global.minY
	maxY = Global.maxY
	
	Col2D.disabled = 0
	
	type = randi() % 3
#	print(type)
	if type == 0:
		AniPlay.playback_speed = 0.75 #normal
		Sprite.texture = alt1
	elif type == 1:
		AniPlay.playback_speed = 0.6 #ducker
		Sprite.texture = alt2
		speed = 75
		howmany += 10
	elif type == 2:
		AniPlay.playback_speed = 0.9 #fast
		Sprite.texture = alt3
		speed = 125
		howmany *= 5

func _process(delta):
	match state:
		STATES.IDLE:
			idle()
		STATES.DOORSPAWN:
			doorspawn()
	
	motion = move_and_slide(motion, Vector2(0,-1))
	Shadow.frame = Sprite.frame
	
	if face_dir == 1:
		set_flipped(false)
	elif face_dir == -1:
		set_flipped(true)
	
	var systemmseconds = OS.get_system_time_msecs()
	if (systemmseconds % 10 == 0):
		playerX = position.x - Global.playerX
		playerY = position.y - Global.playerY
	
	if ouch == 0:
		face_dir = -sign(playerX)
	
#	$Label.text = str("align=",align,"\nplyX=",round(playerX),"\nplyY=",round(playerY),"\ntime=",faketimer,
#	"\nstep=",str(timervalues[timerstep]),"\nhowmany:",howmany,"\ntype:",type)
	
#	print(playerY)
	self.z_index = (position.y/10)-1
	
	if position.y < maxY:
		change_state(STATES.DOORSPAWN)
	
	
	if position.y < maxY: ##246
		position.y += maxY-position.y
		
		if faketimer < -(timervalues[timerstep]*howmany)/2 && ouch == 0 && abs(playerY) < 40 + (howmany*2):
			if type != 1:
				shoot()
			else:
				if howmany > 6:
					howmany -= 5
					faketimer = timervalues[timerstep]
	
	



func _physics_process(delta):
	if faketimer > 0:
		if align == 1:
			faketimer -= 1
		else:
			faketimer -= 0.5
	elif faketimer < 1:
		if align == 1:
			faketimer = 0
		else:
			faketimer -= 1

var face_dir = 1
var playerX = 0
var playerY = minY

var align

func doorspawn():
	if ouch == 0:
		AniPlay.play("walk")#down")
		if position.y > maxY:
			Col2D.disabled = 0
			change_state(STATES.IDLE)
		else:
			motion.x = 0
			motion.y = speed*(-sign(playerY))
	else:
		motion.y = 0
		motion.x = lerp(motion.x,0,0.20)
		AniPlay.play("die")




var howmany = 0 # GLOBAL VALUE ONLY ON SPAWN!! # 

func idle():
	if ouch == 0:
		if abs(motion.x) > 1 or abs(motion.y) > 1: # Walking animation #
			if faketimer < 30: # If almost ready to shoot
				
				if type == 1: #If a ducking enemy, duck if in range
					if abs(playerX) < 200 && abs(playerY) < 50:
						speed = 50
						AniPlay.play("sneak")
						Col2D.scale.y = 0.5
						Col2D.position.y = 19
					else:
						speed = 75
						AniPlay.play("walk")
						Col2D.scale.y = 1
						Col2D.position.y = 0
					
				
				elif abs(type) == 2: #If a dangerous enemy, duck if the player is fucking
					if Input.is_action_pressed("ply_sneak"):
						type = -2
						speed = 60
						AniPlay.play("sneak")
						Col2D.scale.y = 0.5
						Col2D.position.y = 19
					else:
						type = 2
						speed = 125
						AniPlay.play("walkthegun")
						Col2D.scale.y = 1
						Col2D.position.y = 0
					
				
				elif type == 0: #If regular, walk
					AniPlay.play("walkthegun")
					
				
			else: #Walk regularly if time to shoot is still too high
				AniPlay.play("walk")
		
		
		else: #Elif the player is not moving (& ready to shoot)
			AniPlay.stop()
			
			if type == 0 or type == 2:
				Col2D.scale.y = 1
				if align == 1 && faketimer < 30:
					Sprite.frame = 10
				else:
					Sprite.frame = 0
			
			elif type == 1 or type == -2:
				Col2D.scale.y = 0.5
				if align == 1 && faketimer < 30:
					Sprite.frame = 8
				else:
					Sprite.frame = 9
				
		
		### move towards / chase player ###
		if abs(playerY) > (3 + (howmany/2)):#(5 + (howmany/2))
			motion.y = speed*(-sign(playerY))
			align = 0
		else:
			motion.y = 0
			if abs(playerX) > (90 + (howmany*11)): # Distance they'll begin shooting
				align = 0
			else:
				align = 1
		
		
		if align == 0:
			if abs(playerX) > (80 + (howmany*12)): # Distance they'll stop walking towards you
				motion.x = speed*face_dir
			else:
				motion.x = 0
		else:
			motion.x = 0
			if faketimer == 0:
				shoot()
			
			
			
			### ### ### Surrender enemies function ### ### ###
			
			if abs(playerX) < 45 && abs(playerY) < 15: ## beginning ##
				Col2D.scale.y = 1
				Col2D.position.y = 0
				AniPlay.play("giveup")
				
				if type == 0:
					AniPlay.playback_speed = 0.5 #normal
				elif abs(type) == 2:
					AniPlay.playback_speed = 0.25 #ducker
				elif type == 1:
					AniPlay.playback_speed = 0.65 #fast
				
				
				ouch = 2 # if player in range, goto surrending #

	elif ouch == 2: ## surrending ##
		if abs(playerX) < 45 && abs(playerY) < 15:
			AniPlay.playback_speed = 1.5
		else: # if player is too far, goto de-surrending
			ouch = -2
	
	elif ouch == -2: ## de-surrending / resistence ##
		AniPlay.playback_speed = -1
		if abs(playerX) < 45 && abs(playerY) < 15:
			ouch = 2 #if the player is again in range, goto surrending

	elif ouch == 3: ## 'state' reverser ##
		if abs(playerX) < 45 && abs(playerY) < 15:
			ouch = 2 #if the player is again in range, goto surrending
		else: 
			AniPlay.playback_speed = 0.8
			ouch = 0 #de-surrending complete, begin normal behavior

	elif ouch == 4: ## surrender complete ##
		AniPlay.playback_speed = 2
		AniPlay.play("over") #if the player is in range, die
		Col2D.disabled = 1

	else:
		if (timerstep % 2 == 0):
			AniPlay.play("die")
		else:
			AniPlay.play("die2")

func SAFEDIE(): # Secret Scout source-code reference c= #
	Global.foes -= 1
	queue_free()

func diesound():
	$Audio.ENDIEs()

func giveupsound():
	$Audio.TINGa()

export onready var ouch = 0

func take_damage(damage):
	motion.x = 0
	motion.y = 0
	ouch = 1



func shoot():
	$Audio.ENSHOOTa()
	if type == 1:
		timerstep = (randi() % 4) #between 0 and 3
	else: 
		timerstep = (randi() % 9) #between 0 and 8
	faketimer = timervalues[timerstep]
	
	var bul_instance = BUL_ENTITY.instance()
	bul_instance.direction = face_dir
	bul_instance.speed = 300
	bul_instance.who_owner = 1
	bul_instance.position = position+Vector2((30*face_dir),(48))
	
	if type == 1 or type == -2:
		bul_instance.posZ = -46
		howmany += 2
		#speed = 75
	
	else:
		bul_instance.posZ = -77
		howmany += 1
		
	get_parent().add_child(bul_instance)


func set_flipped(flipstate):
	if flipstate: ### LEFT ###
		Sprite.flip_h = true
		Shadow.flip_h = true
	else: ########### RIGHT ###
		Sprite.flip_h = false
		Shadow.flip_h = false
