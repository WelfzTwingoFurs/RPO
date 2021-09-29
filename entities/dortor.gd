extends KinematicBody2D

var radar_icon = "dortor"

var motion = Vector2()
var speed = 130

onready var Sprite = $Sprite
onready var Shadow = $Shadow
onready var AniPlay = $AniPlay
onready var Col2D = $Col2D
onready var Audio = $Audio

enum STATES {IDLE,DOORSPAWN,ENGAGE,SHOOTING,OUCH,GIVEUP}
export(int) var state = STATES.DOORSPAWN

export var minX = 0
export var maxX = 0
# These will be set on startup, and re-adjusted by RayCast2D's in the levels
export var minY = 0
export var maxY = 0

var blockX = 0
var blockY = 0

const BUL_ENTITY = preload("res://entities/bullet-dortor.tscn")

func change_state(new_state):
	state = new_state

const alt1 = preload("res://media/dortorI.png")
const alt2 = preload("res://media/dortorII.png")
const alt3 = preload("res://media/dortorIII.png")

var type

func _ready():
	type = randi() % 3
#	print(type)
	if type == 0:
#		AniPlay.playback_speed = 0.75 #normal
		Sprite.texture = alt1
	elif type == 1:
#		AniPlay.playback_speed = 0.6 #ducker
		Sprite.texture = alt2
#		speed = 75
#		howmany += 10
	elif type == 2:
#		AniPlay.playback_speed = 0.9 #smart
		Sprite.texture = alt3
#		speed = 125
#		howmany *= 5
	
	timerstep = (randi() % 7)
	
	Global.foes += 1
	
	howmany = Global.foes
	
	if howmany == 0:
		howmany = 1
	
	Col2D.disabled = 0

func _physics_process(delta):
	motion = move_and_slide(motion, Vector2(0,-1))
	
	if state == 2: #Aka ENGAGE
		if faketimer > 0:
			faketimer -= 1
		elif faketimer == 0:
			wasplyY = round(playerY)
			change_state(STATES.SHOOTING)
	else:
		pass


func _process(delta):
	match state:
		STATES.IDLE:
			walkdown = 0
			idle()
		STATES.DOORSPAWN:
			doorspawn()
		STATES.ENGAGE:
			engage()
		STATES.SHOOTING:
			shooting()
		STATES.OUCH:
			var damage
			take_damage(damage)
		STATES.GIVEUP:
			surrender()
	
	Shadow.frame = Sprite.frame
	
	if face_dir == 1:
		set_flipped(false)
	elif face_dir == -1:
		set_flipped(true)
	
	
	
	system_msecs = OS.get_system_time_msecs()
	
	if state != 1:# && walkdown == 0:
		if position.y < maxY:
			position.y += 1
		
		elif position.y > minY:
			position.y -= 1
		
#		if position.x > maxX:
#			position.x += maxX-position.x
#		elif position.x < minX:
#			position.x += minX-position.x
		
		self.z_index = round(position.y/10)-1
#	else:
#		if position.y < maxY:
#			doorspawn()

	if state == 0 && chasehq == 0: #If in idle, delay notice
		
		if ((howmany*2)*1000) % 10000 == 0: #I forgot what the fuck this does
			howmany = (howmany/10) + 1 
		#if abs(playerX) < sight
		var Xtest = position.x - Global.playerX
		if Xtest > 200:
			if (system_msecs % ((howmany*2)*1000)) == 0:# every 'howmany'*2 seconds
				playerX = position.x - Global.playerX #This works half-well, number may be to high and make way too long to notice
				playerY = position.y - Global.playerY #so I made it also update the position if the player is simply too close
		else:
			playerX = position.x - Global.playerX
			playerY = position.y - Global.playerY
			
	else: #Else, don't, or they'll be unpredicable to surrender
		if (system_msecs % 200) == 0:# 500 works bad, should be half-a-sec, but Godot sometimes skips milliseconds
			playerX = position.x - Global.playerX
			playerY = position.y - Global.playerY
			
	
	
#	$Debug.text = str("wasfaketimer:",wasfaketimer,"\nfaketimer:",faketimer,"\nstate:",state,
#	"\nplayerX:",round(playerX),", playerY:",round(playerY),"\nwasplyY:",wasplyY,"\ngiveupvar:",giveupvar,
#	"\nhowmany:",howmany," check:",((howmany*2)*1000))
	
	
	if state != 4:
		if abs(playerX) < 45 && abs(playerY) < 15 && giveupvar != 4: ## beginning ##
			giveupvar = 2
			AniPlay.play("giveup")
			change_state(STATES.GIVEUP)

var walkdown = 1

var system_msecs

var faketimer = 1
var timerstep = 1
var timervalues = [80,91,102,113,154,45,66]
var wasfaketimer = 1
#timerstep = (randi() % 7) #between 0 and 6
#faketimer = timervalues[timerstep]

var howmany

var face_dir = -1
var playerX = 46
var playerY = 16

var target
var sight = 0

var wasplyY = 1

var chasehq = 0

func idle():
	motion.x = 0
	if abs(playerX) < sight:
		sight = get_viewport().size.x-(Global.resolution*70)
		timerstep = (randi() % 7) #between 0 and 6
		faketimer = timervalues[timerstep]
		wasfaketimer = faketimer
		chasehq = 0
		change_state(STATES.ENGAGE)
	else:
		if sign(playerX) == -1: #If the player is to the right, chase them
			AniPlay.play("walk")
			chasehq = 1
			face_dir = 1
			if blockX != face_dir:
				motion.x = (speed*face_dir)*1.5#face_dir)*1.5
		else:
			chasehq = 0
			if (timerstep % 2 == 0): #Else, idle
				AniPlay.play("idle2")
			else:
				AniPlay.play("taunt")

func engage():
	if abs(playerX) > sight-howmany:
		sight = get_viewport().size.x-(Global.resolution*70)
		change_state(STATES.IDLE)
	
	if abs(motion.x) > 1 or abs(motion.y) > 1: # Walking animation #
		#if walkdown == 1:
		#	AniPlay.play("walkdown")
		#else:
		AniPlay.play("walkback")
	else:
		AniPlay.play("gonnashoot")
	face_dir = -sign(playerX)
	
	if faketimer < (wasfaketimer/1.5):
		if blockX != face_dir:
			motion.x = speed*-face_dir
		else:
			motion.x = 0
			#motion.x = lerp(motion.x,speed,0.1)*-face_dir
		
		
		if abs(playerY) < 25+howmany:
			if blockY != -(sign(playerY)):
				motion.y = speed*sign(playerY)
			else:
				motion.y = 0
			
			#motion.y = lerp(0,speed,0.5)*sign(wasplyY)
		#else:
		#	motion.y = 0
	


export var giveupvar = 0

func surrender():
	motion.x = 0
	motion.y = 0
	if giveupvar == 2: ## surrending ##
		if abs(playerX) < 45 && abs(playerY) < 15:
			AniPlay.playback_speed = 1.5
		else: # if player is too far, goto de-surrending
			giveupvar = -2
	
	elif giveupvar == -2: ## de-surrending / resistence ##
		AniPlay.playback_speed = -1
		if abs(playerX) < 45 && abs(playerY) < 15:
			giveupvar = 2 #if the player is again in range, goto surrending

	elif giveupvar == 3: ## 'state' reverser ##
		if abs(playerX) < 45 && abs(playerY) < 15:
			giveupvar = 2 #if the player is again in range, goto surrending
		else: 
			AniPlay.playback_speed = 1
			giveupvar = 0 #de-surrending complete, begin normal behavior
			change_state(STATES.ENGAGE)

	elif giveupvar == 4: ## surrender complete ##
		#Col2D.disabled = 1
		#remove_radar()
		AniPlay.play("giveupover")

#lerp(from: Variant, to: Variant, weight: float)

func remove_radar():
	self.remove_from_group('radar_me')

func doorspawn():
	walkdown = 1
	AniPlay.play("walkdown")
	motion.y = speed
	if position.y > maxY:
		motion.y = 0
		sight = get_viewport().size.x-(Global.resolution*70)
		walkdown = 0
		
		change_state(STATES.IDLE)

func shooting():
	motion.y = 0
	motion.x = 0
	wasfaketimer = faketimer
	
	if wasplyY > 65:
		AniPlay.play("throwUp")
		bulletY = -1
	elif wasplyY < -65:
		AniPlay.play("throwDown")
		bulletY = 1
	else:
		bulletY = 0
		if (timerstep % 2 == 0):
			AniPlay.play("throwSide")
		else:
			AniPlay.play("throwSideII")

var bulletY = 0

func shoot():
	wasplyY = round(playerY)
	timerstep = (randi() % 7) #between 0 and 6
	faketimer = timervalues[timerstep]
	
	$Audio.JUMPa()
	var bul_instance = BUL_ENTITY.instance()
	
	bul_instance.dirY = bulletY
	
	if abs(playerX) > 45:
		bul_instance.dirX = face_dir
	else:
		if bulletY != 0:
			bul_instance.dirX = 0
		else:
			bul_instance.dirX = face_dir
	
	bul_instance.position = position+Vector2((30*face_dir),(48))
	bul_instance.posZ = 48
	
	get_parent().add_child(bul_instance)

func take_damage(damage):
	motion.x = 0
	motion.y = 0
	
	#Col2D.disabled = 1
	change_state(STATES.OUCH)
	if (timerstep % 2 == 0):
		AniPlay.play("die1")
	else:
		AniPlay.play("die2")

func SAFEDIE():
	Global.foes -= 1
	queue_free()

func giveupScore():
	Global.player.score += 2000
	Global.player.arrests += 1

func dropitem():
	pass

func set_flipped(flipstate):
	if flipstate: ### LEFT ### -1
		Sprite.flip_h = true
		Shadow.flip_h = true
	else: ########### RIGHT ### 1
		Sprite.flip_h = false
		Shadow.flip_h = false
