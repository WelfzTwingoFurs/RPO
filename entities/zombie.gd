extends KinematicBody2D

var motion = Vector2()
var speed = 100

var radar_icon = "zombie"

onready var Sprite = $Sprite
onready var Shadow = $Shadow
onready var AniPlay = $AniPlay
onready var Col2D = $Col2D


export var zombie = 0

var dortor_dad

export var minX = 0
export var maxX = 0
# These will be set here, and exported to the spawning entities
export var minY = 0
export var maxY = 0

var blockX
var blockY

enum STATES {ZOMBIFY,IDLE,DIE}
export(int) var state = STATES.ZOMBIFY


func change_state(new_state):
	state = new_state


func _ready():
	if minX == 0:
		minX = Global.minX
	if maxX == 0:
		maxX = Global.maxX
	if minY == 0:
		minY = Global.minY
	if maxY == 0:
		maxY = Global.maxY
	
	Global.foes += 1
	ani_busy = 0
	$AniPlay.play("cloro-drink")
	
	if dortor_dad == null:
		zombie = 1




func _process(_delta):
	if position.y < maxY:
		position.y += 1
		
	elif position.y > minY:
		position.y -= 1
	
	
	motion = move_and_slide(motion, Vector2(0,-1))
	
	match state:
		STATES.ZOMBIFY:
			#Col2D.disabled = 1
			zombify()
		STATES.IDLE:
			Col2D.disabled = 0
			idle()
		STATES.DIE:
			Col2D.disabled = 1
			die()
	
	if face_dir != 0:
		Sprite.scale.x = face_dir
		Shadow.scale.x = face_dir
	
	Shadow.frame = Sprite.frame
	
	system_msecs = OS.get_system_time_secs()
	
	self.z_index = (position.y/10)-1
	
	playerX = abs(position.x - player_target.x)
	playerY = abs(position.y - player_target.y)

var system_msecs = 0

var fearsight

export var fear = 0

func zombify():
	
	
	
	if dortor_dad == null:
		change_state(STATES.IDLE)
	else:
		if zombie == 0:
			if dortor_dad != null:
				if dortor_dad.dead != 0:
					humanize()
			
			if Global.player.holster == -1: #Copied over from NPC-B
				fearsight = abs(get_viewport().size.x)/6
				
				if abs(position.x - Global.player.position.x) < fearsight && abs(position.y - Global.player.position.y) < 40:
					
					if -sign(position.x - Global.player.position.x) != Global.player.face_dir:
						#if Global.player.face_dir != face_dir:
							
						face_dir = sign(position.x - Global.player.position.x)
						humanize()
			
			
		elif zombie == 1:
			AniPlay.play("cloro-transform")
			

func null_dortor_dad():
	dortor_dad = null

func idle():
	if health > 0:
		if ani_busy == 0:
			if (system_msecs % 2) == 0:
				player_lookfor()
			elif (system_msecs % 3) == 0:
				if check_ing != system_msecs:
					check_ing = system_msecs
					$Audio.zombie_spawn()
			
			
			
			AniPlay.play("cloro-walk")
			
			if playerX < 65 && playerY < 15:
				punch()
			else:
				motion.x = speed*face_dir
				motion.y = speed*face_dirY
		else:
			player_lookfor()
			if punch_now == 1:
				punch_player()
	else:
		which = (randi() % 2)
		change_state(STATES.DIE)

export var ani_busy = 0



export var punch_now = 0

var which = 0

func punch():
	motion.x /= 2
	motion.y /= 3
	
	
	
	AniPlay.playback_speed = 1.7
	which = (randi() % 3)
	
	if which == 0:
		AniPlay.play("cloro-attack1")
	elif which == 1:
		AniPlay.play("cloro-attack2")
	elif which == 2:
		AniPlay.play("cloro-attack3")
	
	check_random = (randi() % 99)



var check_random
var check_ing

func punch_player():
	motion.x = 0
	motion.y  = 0
	punch_now = 0
	
	var playerZ = player_body.positionZ
	
	#print(playerZ)
	
	
	if check_random != check_ing:
		check_random = check_ing
		
		if playerX < 65:
			if playerY < 40:
				if playerZ > -120:
					$Audio.zombie_hit()
					player_body.take_damage(14)
					player_body.position.x += face_dir*10
					player_body.player_speed = 0



var players_in_scene = []
var player_target = Vector2(INF,INF)

var sight

var face_dir = 1
var face_dirY = 0

var playerX = INF
var playerY = INF

var player_body

func player_lookfor():
	players_in_scene = get_tree().get_nodes_in_group("player")
	sight = abs(get_viewport().size.x)/2#-(Global.resolution*70)
	
	if players_in_scene.size() != 0:
		for item in players_in_scene:
			var wr = weakref(item)
			
			if (wr.get_ref()):
				if (item.position.x - position.x) < sight:
					player_target = Vector2(item.position)
					
					face_dir = sign(item.position.x - position.x)
					face_dirY = sign(item.position.y - position.y)
					
					player_body = item
	else:
		player_target = Vector2(INF,INF)

onready var health = 3

func take_damage(_damage):
	if dortor_dad != null:
		print(dortor_dad)
		humanize()
	
	else:
		$Audio.zombie_ouch()
		health -= 1
		if ani_busy == 0:
			position.x -= face_dir*20
		else:
			position.x -= face_dir*4
	


var npcb_was

func humanize():
	var cloroman = load("res://entities/NPC-B.tscn")
	var cloro_instance = cloroman.instance()
	
	cloro_instance.position = position
	cloro_instance.face_dir = -face_dir
	
	cloro_instance.minX = minX
	cloro_instance.minY = minY
	cloro_instance.maxX = maxX
	cloro_instance.maxY = maxY
	
	cloro_instance.dortor_dad = dortor_dad
	
	cloro_instance.npcb = npcb_was
	
	if dortor_dad != null:
		if dortor_dad.dead != -1: # Dortor surrendered, humazine without fear
			cloro_instance.fear = -1
	
	
	get_parent().add_child(cloro_instance)
	
	queue_free()

func die():
	motion.x = 0
	motion.y = 0
	AniPlay.playback_speed = 1
	
	if which == 0:
		AniPlay.play("die1")
	elif which == 1:
		AniPlay.play("die2")


func set_flipped(flipstate):
	if flipstate: ### LEFT ### -1
		Sprite.flip_h = true
		Shadow.flip_h = true
	else: ########### RIGHT ### 1
		Sprite.flip_h = false
		Shadow.flip_h = false

func SAFEDIE(): # Secret Scout source-code reference c= #
	Global.foes -= 1
	queue_free()
