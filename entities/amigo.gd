extends KinematicBody2D

var radar_icon = "player2"

var motion = Vector2()

onready var Sprite = $Sprite
onready var Shadow = $Shadow
onready var AniPlay = $AniPlay
onready var Col2D = $Col2D
onready var barrelp = $TexProg


export var minX = 0
export var maxX = 0
# These will be set on startup, and re-adjusted by RayCast2D's in the levels
export var minY = 0
export var maxY = 0

var blockX = 0
var blockY = 0
var blockZ = 0
var positionZ = 0

enum STATES {IDLE,TIED,DIE,CLORO}
export(int) var state = STATES.TIED

func change_state(new_state):
	state = new_state

func _ready():
	helptrigger = 0
	AniPlay.play("helpme")
	barrelp.value = 0
	if ready == 1:
		Global.friends += 1
		AniPlay.playback_speed = 0.8
		change_state(STATES.IDLE)

export var ready = 0

var playerX = 0
var playerY = 0

var face_dir = 1

func _process(delta):
	match state:
		STATES.IDLE:
			idle()
		STATES.TIED:
			tied()
		STATES.DIE:
			die()
		STATES.CLORO:
			take_cloroquina()
	
	motion = move_and_slide(motion, Vector2(0,-1))
	Shadow.frame = Sprite.frame
	
	self.z_index = round(position.y/10)-1
	
	
	if face_dir == 1:
		set_flipped(false)
	elif face_dir == -1:
		set_flipped(true)
	
	if Global.foes > 1:
		foes = Global.foes
		friends = Global.friends
	
	playerX = position.x - Global.player.position.x
	playerY = position.y - Global.player.position.y

export var helptrigger = 0

export var barrelpvar = 0

func tied():
	Col2D.disabled = 1
	
	if abs(playerX) < 60 && abs(playerY) < 30:
		
		barrelp.value = barrelpvar
		
		AniPlay.play("beinghelped")
		AniPlay.playback_speed = 0.5
	else:
		AniPlay.playback_speed = -1
	
	if helptrigger == 1:
		Global.friends += 1
		initialoffset = Global.friends
		AniPlay.playback_speed = 0.8
		barrelp.queue_free()
		Global.player.score += 200
		change_state(STATES.IDLE)
	elif helptrigger == -1 && AniPlay.playback_speed == -1:
		AniPlay.playback_speed = 1
		AniPlay.play("helpme")
		barrelp.value = 0
		helptrigger = 0



var foes = 0
var friends = 0
var initialoffset = 0

const SPEED = 145

var faketimer = 0


func idle():
	Col2D.disabled = 0
	face_dir = -(sign(playerX))
	
	if abs(motion.x) < 1 && abs(motion.y) < 1:
		if shoottrigger == 0:
			AniPlay.play("idle")
		else:
			AniPlay.stop()
			Sprite.frame = 10
	else:
		if shoottrigger == 0:
			AniPlay.play("walk")
		else:
			AniPlay.play("walkgun")
	
	
	if abs(playerX) > 25 +((initialoffset*4)*initialoffset) -((foes*3)*foes):
		if abs(playerX) > (initialoffset*5 +1):
			motion.x = lerp(motion.x,(SPEED*(-sign(playerX))),0.05)#(0.05-(initialoffset/100)))
		else:
			motion.x = 0
	else:
		motion.x = 0
	
	if abs(playerY) > 15 +(initialoffset*2) -(foes*foes):
		if abs(playerY) > (initialoffset*2 +1):
			motion.y = lerp(motion.y,(SPEED*(-sign(playerY))),0.05)#0.5-(initialoffset/100))
		else:
			motion.y = 0
	else:
		motion.y = 0
	
	
	if faketimer > 0:
		faketimer -= 0.1
	
	if Input.is_action_just_pressed("ply_shoot"):
		faketimer = 10 + (initialoffset*2)
		shoottrigger = 1
		var player = Global.player
		keep_facing = player.face_dir
		
	if shoottrigger == 1:
		if (initialoffset % 2 == 0):
			face_dir = keep_facing
		else:
			face_dir = -keep_facing
		
		if faketimer < 0:
			faketimer = 13
			shoot()

var shoottrigger = 0

var keep_facing

const bul_entity = preload("res://entities/bullet.tscn")
func shoot():
	$Audio.SHOOTs()
	var bul_instance = bul_entity.instance()
	bul_instance.direction = face_dir
	bul_instance.who_owner = 0
	bul_instance.position = position+Vector2((30*face_dir),(48))
	bul_instance.posZ = -67
	get_parent().add_child(bul_instance)
	
	if !Input.is_action_pressed("ply_shoot"):
		shoottrigger = 0


func take_damage(damage):
	motion.x = 0
	motion.y = 0
	change_state(STATES.DIE)

func take_cloroquina():
	change_state(STATES.CLORO)
	motion.x = 0
	motion.y = 0
	AniPlay.play("transform")

func die():
	AniPlay.play("die")

func SAFEDIE():
	Global.friends -= 1
	queue_free()



func transformation():
	Global.friends -= 1
	var whotospawn = preload("res://entities/zombie.tscn")
	var bul_instance = whotospawn.instance()
	bul_instance.position = Vector2(position.x,position.y)
#	bul_instance.type = 1
	
	bul_instance.minX = minX
	bul_instance.maxX = maxX
	bul_instance.minY = minY
	bul_instance.maxY = maxY
	
	get_parent().add_child(bul_instance)
	queue_free()

func set_flipped(flipstate):
	if flipstate: ### LEFT ###
		Sprite.flip_h = true
		Shadow.flip_h = true
	else: ########### RIGHT ###
		Sprite.flip_h = false
		Shadow.flip_h = false
