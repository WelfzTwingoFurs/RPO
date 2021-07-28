extends KinematicBody2D

var motion = Vector2()
var speed = 130

onready var Sprite = $Sprite
onready var Shadow = $Shadow
onready var AniPlay = $AniPlay
onready var Col2D = $Col2D
onready var Audio = $Audio

enum STATES {IDLE,DOORSPAWN,ENGAGE,SHOOTING,OUCH,GIVEUP}
export(int) var state = STATES.DOORSPAWN

var minX = 0
var maxX = 973
# These will be set in-level, exported to global, then imported to entities.
var minY = 350
var maxY = 246


const BUL_ENTITY = preload("res://entities/bullet-dortor.tscn")

func change_state(new_state):
	state = new_state

func _ready():
	timerstep = (randi() % 7)
	
	Global.foes += 1
	
	howmany = Global.foes
	
	if howmany < 1:
		howmany = 1
	
	minX = Global.minX
	maxX = Global.maxX
	minY = Global.minY
	maxY = Global.maxY
	
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
	
#	if position.y < maxY:
#		change_state(STATES.DOORSPAWN)
	
	if face_dir == 1:
		set_flipped(false)
	elif face_dir == -1:
		set_flipped(true)
	
#	$Debug.text = str("wasfaketimer:",wasfaketimer,"\nfaketimer:",faketimer,"\nstate:",state,
#	"\nplayerX:",round(playerX),", playerY:",round(playerY),"\nwasplyY:",wasplyY,"\ngiveupvar:",giveupvar)
	
	if position.y > minY: #460
		position.y += minY-position.y
	elif position.y < maxY: ##246
		position.y += maxY-position.y
	
	if position.x > maxX: ##2900
		position.x += maxX-position.x
	elif position.x < minX: #0
		position.x += minX-position.x
	
	self.z_index = round(position.y/10)-1
	
#	var systemseconds = OS.get_system_time_secs()
	var systemmseconds = OS.get_system_time_msecs()
	
	if state == 1:
		if (systemmseconds % 100000 == 0):#every 20 seconds? if 1000 is 1 second
			playerX = position.x - Global.playerX
			playerY = position.y - Global.playerY
	else:
		if (systemmseconds % 10 == 0):#every half-second
			playerX = position.x - Global.playerX
			playerY = position.y - Global.playerY
	
	if state != 4:
		if abs(playerX) < 45 && abs(playerY) < 15 && giveupvar != 4: ## beginning ##
			giveupvar = 2
			AniPlay.play("giveup")
			change_state(STATES.GIVEUP)

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

func idle():
	motion.x = 0
	if abs(playerX) < sight:
		sight = get_viewport().size.x-(Global.resolution*70)
		timerstep = (randi() % 7) #between 0 and 6
		faketimer = timervalues[timerstep]
		wasfaketimer = faketimer
		change_state(STATES.ENGAGE)
	else:
		if (timerstep % 2 == 0):
			AniPlay.play("idle2")
		else:
			AniPlay.play("taunt")

func engage():
	if abs(playerX) > sight-howmany:
		sight = get_viewport().size.x-(Global.resolution*70)
		change_state(STATES.IDLE)
	
	if abs(motion.x) > 1 or abs(motion.y) > 1: # Walking animation #
		AniPlay.play("walkback")
	else:
		AniPlay.play("gonnashoot")
	face_dir = -sign(playerX)
	
	if faketimer < (wasfaketimer/1.5):
		motion.x = speed*-face_dir
		#motion.x = lerp(motion.x,speed,0.1)*-face_dir
		
		
		if abs(playerY) < 25+howmany:
			motion.y = speed*sign(playerY)
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
		AniPlay.play("giveupover")

#lerp(from: Variant, to: Variant, weight: float)

func doorspawn():
	AniPlay.play("walkdown")
	motion.y = speed
	if position.y > maxY:
		motion.y = 0
		sight = get_viewport().size.x-(Global.resolution*70)
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

func set_flipped(flipstate):
	if flipstate: ### LEFT ### -1
		Sprite.flip_h = true
		Shadow.flip_h = true
	else: ########### RIGHT ### 1
		Sprite.flip_h = false
		Shadow.flip_h = false
