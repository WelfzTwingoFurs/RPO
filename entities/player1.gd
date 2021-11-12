extends KinematicBody2D

var radar_icon = "player1"

const GRAVITY = 9.5
var SPEED = 150
const MAXSPEED = 300
const JUMP = -26

const SPRITE1 = preload("res://media/player_aspone.png")
const SPRITE2 = preload("res://media/player_aspone-holster.png")

const SHADOW1 = preload("res://media/player_shadow.png")
const SHADOW2 = preload("res://media/player-holster_shadow.png")

onready var Sprite = $Sprite
onready var Shadow = $Shadow
onready var AnimationPlayer = $AnimationPlayer
onready var Debug = $CanvasLayer/Debug
onready var Audio = $Audio
onready var Audio2 = $Audio2
onready var Audio3 = $Audio3

onready var hud_lborder = $CanvasLayer/LBorder
onready var hud_play1 = $CanvasLayer/LBorder/Player1
onready var hud_radar = $CanvasLayer/LBorder/Radar
onready var hud_play2 = $CanvasLayer/LBorder/Player2
onready var hud_rborder = $CanvasLayer/LBorder/RBorder
onready var hud_extender = $CanvasLayer/LBorder/Extender

onready var hud_lifebar = $CanvasLayer/LBorder/Player1/Life1
onready var hud_ammo1 = $CanvasLayer/LBorder/Player1/Ammo1


onready var hud_score1 = $CanvasLayer/LBorder/Player1/Score1
onready var hud_score2 = $CanvasLayer/LBorder/Player2/Score2

onready var hud_money1 = $CanvasLayer/LBorder/Player1/iMoney1
onready var hud_money2 = $CanvasLayer/LBorder/Player2/iMoney2

onready var hud_cloro1 = $CanvasLayer/LBorder/Player1/iCloro1
onready var hud_cloro2 = $CanvasLayer/LBorder/Player2/iCloro2

onready var hud_can1 = $CanvasLayer/LBorder/Player1/iCan1
onready var hud_can2 = $CanvasLayer/LBorder/Player2/iCan2

onready var hud_arrests1 = $CanvasLayer/LBorder/Player1/iArrest1
#onready var hud_can2 = $CanvasLayer/LBorder/Player2/iCan2

onready var Col2D = $Col2D

var input_dirX = 0
var input_dirY = 0
var face_dir = 1
var last_dir = 0

var motionZ = 0
var positionZ = 0

export var aniframe = 0

enum STATES {IDLE,OUCH,DRIVE}
export(int) var state = STATES.IDLE

var motion = Vector2()

export var minX = 0
export var maxX = 0
# These will be set on startup, and re-adjusted by RayCast2D's in the levels
export var minY = 0
export var maxY = 0

var blockX
var blockY
var blockZ = 0

export var itembusy = 0
var vailagga = 0

export var lane1 = 0 #336
export var lane2 = 0 #440

func _ready():
	if minX == 0:
		minX = Global.minX
	if maxX == 0:
		maxX = Global.maxX
	if minY == 0:
		minY = Global.minY
	if maxY == 0:
		maxY = Global.maxY
	
	Global.player = self
	
	Global.minX = minX
	Global.maxX = maxX
	Global.minY = minY
	Global.maxY = maxY
	
	Global.lane1 = lane1
	Global.lane2 = lane2
	
	
	$Camera2D.limit_left = minX - 25
	$Camera2D.limit_right = maxX
	
	$Camera2D.limit_bottom = minY + 157
#	$Camera2D.limit_top = -maxY
	
	hudconfig()
	
	
	AnimationPlayer.playback_speed = 0.8
	
	if holster == 1:
		Sprite.set_texture(SPRITE2)
		Shadow.set_texture(SHADOW2)
	elif holster == -1:
		Sprite.set_texture(SPRITE1)
		Shadow.set_texture(SHADOW1)




func change_state(new_state):
	Sprite.position.x = 0
	Col2D.scale.y = 1
	
	state = new_state

var player

var score = 0

var ammo1 = 99
var ammo2 = 5

var moneys = 0
var cloros = 0
var cans = 0
var arrests = 0

var system_msecs

func score_commas(score): #commas in numbers
	var string = str(score)
	var mod = string.length() % 3
	var res = ""
	
	for i in range(0, string.length()):
		if i != 0 && i % 3 == mod:
			res += ","
		res += string[i]
	
	hud_score1.text = str(res)



func _process(_delta):
	# Hud #
	hud_lifebar.value = health
	hud_ammo1.text = str(ammo1)#,"\n",ammo2)
	
	#hud_score1.text = str(score_commas(score))
	score_commas(score)
	
	if itembusy != 0:
		vailagga = abs(sin(system_msecs))
		
		hud_score1.set("custom_colors/font_color",Color(1,vailagga,1))
		
	else:
		hud_score1.set("custom_colors/font_color",Color(1,0,1))


	if moneys != 0:
		hud_money1.visible = 1
		hud_money1.text = str(moneys)
	if cloros != 0:
		hud_cloro1.visible = 1
		hud_cloro1.text = str(cloros)
	if cans != 0:
		hud_can1.visible = 1
		hud_can1.text = str(cans)
	if arrests != 0:
		hud_arrests1.visible = 1
		hud_arrests1.text = str(arrests)
	
	system_msecs = OS.get_system_time_msecs()
	
	
#	if position.y < maxY:
#		position.y += 1
#	if position.y > minY:
#		position.y -= 1
	
	
	match state:
		STATES.IDLE:
			idle()
		STATES.OUCH:
			pass # take_damage()
		STATES.DRIVE:
			driving()
			
	
	motion = move_and_slide(motion, Vector2(0,-1))
	Shadow.frame = Sprite.frame
	
	self.z_index = round(position.y/10)
	
	
	if state != 2:
		$Col2D.position.y = positionZ + bul_pos/1.5
		
		if onfloor == 2:
			bul_pos = 31
			$Col2D.scale.y = 0.7
		elif onfloor == 0:
			bul_pos = 20
		else:
			if !Input.is_action_pressed("ply_sneak"):# Won't work otherwise, no clue
				bul_pos = 0
				$Col2D.scale.y = 1
	
	if abs(holster) != 2:
		if Input.is_action_pressed("ply_moveleft"):
			#if blockX != -1:
			input_dirX = -1
			#else:
			#	input_dirX = 0
		elif Input.is_action_pressed("ply_moveright"):
			#if blockX != 1:
			input_dirX = 1
			#else:
			#	input_dirX = 0
		else:
			input_dirX = 0

		if Input.is_action_pressed("ply_moveup"):
			#if blockY != -1:
			input_dirY = -1
			#else:
			#	input_dirY = 0
		elif Input.is_action_pressed("ply_movedown"):
			#if blockY != 1:
			input_dirY = 1
			#else:
			#	input_dirY = 0
		else:
			input_dirY = 0
	else:
		input_dirX = 0
		input_dirY = 0



	if face_dir == 1:
		set_flipped(false)
	elif face_dir == -1:
		set_flipped(true)
	
	if input_dirX != 0:
		if last_dir == 0:
			face_dir = input_dirX
	
	
	if spawn_on != 0:
		if (system_msecs % spawn_frequency) == 0:
			spawner()
	
	
	
	
	
	
	
	
	
	
	if debugger == 1:
		Debug.text = str("limits: ^(",maxY,") v(",minY,") <(",minX,") >(",maxX,")\n",
		"input: X(",input_dirX,") Y(",input_dirY, "), face(",face_dir,")\n",
		"motion: X(",round(motion.x),") Y(",round(motion.y),") Z(",motionZ,"), A(",round(player_speed),")\n",
		"position: X(",round(position.x),") Y(",round(position.y),") Z(",round(positionZ),")\n",
		"onfloor(",onfloor,"), bul-pos(",(positionZ-67)+bul_pos,")\n",
		"aniframe(",aniframe,") Sprite.frame(",Sprite.frame,")\n",
		"spriteplus/shooting(",shooting,") ouch(",ouch,")\n",
		"faketimer(",faketimer,"), ammo: I(",ammo1,") II(",ammo2,")\n",
		"NPCs:",Global.npcs,", Foes: ",Global.foes,", Friends: ",Global.friends,
		"\nWindow: X(",windowX,") Y(",windowY,"), Zoom:",zoom,"\n Speed:",Engine.time_scale,
		", FPS:",Engine.get_frames_per_second(),", itembusy:",itembusy,"\nBlock: x(",blockX,") y(",blockY,") z(",blockZ,")\n",
		"holster:",holster,". Interest ",Global.interest_type," at ",round(Global.point_of_interest.x),"//",round(Global.point_of_interest.y))

	if onfloor == 2:
		player_speed = lerp(player_speed,(SPEED/1.9),0.10)
	# no clue why but this only works in _process. cockballs #

var debugger = 1
var player_speed = 0

#Radar is 113 pixels wide;
#Stats are 184, together 368;
#The borders are 6, together are 12;
#Altogether they are 493!

#if the window is smaller than that, stats will be on top of the radar.
#So, if that's the case, give up the log area

func hudconfig():
	zoom = Global.resolution
	windowX = get_viewport().size.x
	windowY = get_viewport().size.y
	screen = OS.get_screen_size()

	if windowY < minY*2:
		$Camera2D.position.y = minY - windowY

	#In 4:3, it's 640x480 at zoom 1

#########################################################################################################
	hud_rborder.position.x = screen.x/zoom

	hud_radar.position.x = (windowX / 2) -56# sprite's X divided by 2
	hud_extender.scale.x = windowX / 6#sprite's X

	hud_lborder.position.y = windowY -87 -(40/zoom)# sprite's Y & Windows 10's deskbar

	if windowX < 481:
		hud_play1.position.x = -10#(windowX / 2) /(zoom+1)
		hud_play2.position.x = (screen.x/zoom) -174# sprite's X
	elif windowX > 481 && windowX < 493:
		hud_play1.position.x = 5#(windowX / 2) /(zoom+1)
		hud_play2.position.x = (screen.x/zoom) -187# sprite's X
	else:
		hud_play1.position.x = (windowX / 2) /(zoom+1)
		hud_play2.position.x = (windowX / 2) +((windowX / 2)-(hud_play1.position.x)) -184# sprite's X
#########################################################################################################

var zoom
var screen
var windowX
var windowY

#func hudconfig():
#	zoom = Global.resolution
#	windowX = get_viewport().size.x
#	windowY = get_viewport().size.y
#	screen = OS.get_screen_size()
#
#	if windowY < minY*2:
#		$Camera2D.position.y = minY - windowY
#
#	hud_rborder.position.x = screen.x/zoom
#	hud_radar.position.x = (windowX / 2) -56#Sprite's X divided by 2
#	hud_extender.scale.x = windowX / 6#sprite's X
#
#	hud_play1.position.x = (windowX / 2) /(zoom+1)
#	hud_play2.position.x = (windowX / 2) +((windowX / 2)-(hud_play1.position.x)) -184#Sprite's X
#
#	hud_lborder.position.y = windowY -87 -(40/zoom)#Sprite's Y & Windows 10's deskbar
#
#	$Camera2D.drag_margin_top = 2/zoom
#	$Camera2D.drag_margin_bottom = 2/zoom



func _physics_process(_delta):
	Sprite.position.y = positionZ
	
	if Global.foes < 0:
		Global.foes = 0
	
	
	if blockZ == 0:
		if motionZ < 0:
			motionZ += 1
		
		positionZ += motionZ
		
		if positionZ < 0:
			positionZ += GRAVITY
			
			if !Input.is_action_pressed("ply_jump"):
				motionZ += 0.5
			
		elif positionZ > 0:
			positionZ = 0
			motionZ = 0
		else:
			onfloor = 1
	
	
	if faketimer > 0:
		faketimer -= 1
	
	if clorotimer > 1:
		SPEED = 100
		clorotimer -= 1
		
		var meganumbers = sin(OS.get_system_time_msecs()) / ((((clorotimer)+1)/20)+1)*1.5
		
		Sprite.set_modulate(Color(1+meganumbers,1+meganumbers,1))
		#Sprite.set_modulate(Color(1+meganumbers,1,1+meganumbers))
		
	else:
		Sprite.set_modulate(Color(1,1,1))
		SPEED = 150
	
	if onfloor == 0:
		if positionZ < -50:
			player_speed += 4
	elif onfloor == 1:
		player_speed = lerp(player_speed,SPEED,0.05)
	
	if positionZ == 0 && motionZ == 0 && Sprite.frame == 7:
		$Audio2.LANDa() #Bodged but functional for now



var onfloor

# CTRL + R
#+spriteplus
#+spriteplus
# OR ACTUALLY, make shooting = on be shooting = 10, and get rid of spriteplus!
#var spriteplus = 0 # First bodge so far? nah that was player_speed, but that turned out cooler than before
var bul_pos = 0  # Here's another bodge, inspired directly by the one above

var shooting = 0
var faketimer = 0

const bul_entity = preload("res://entities/bullet.tscn")


func die():
	last_dir = face_dir
	ouch = 1
	$Col2D.disabled = 1
	Sprite.frame = aniframe
	AnimationPlayer.play("die")
	motion.x = lerp(motion.x,0,0.005)
	motion.y = lerp(motion.y,0,0.010)

func shoot():
	$Audio2.SHOOTs()
	var bul_instance = bul_entity.instance()
	bul_instance.direction = face_dir
	bul_instance.who_owner = 0
	bul_instance.position = position+Vector2((30*face_dir),(48))
	bul_instance.posZ = (positionZ-67)+bul_pos #positionZ-67-bul_pos
	
	bul_instance.maxX = maxX
	bul_instance.minX = minX
	bul_instance.maxY = maxY-1
	bul_instance.minY = minY+65#+49 is correct, but higher makes for better shooting simply
	
	get_parent().add_child(bul_instance)

export var holster = -1

func idle():
	change_state(STATES.IDLE)
	if health < 1:
		die()
	
	if ouch == 0:
		if Input.is_action_just_pressed("ply_holster") && onfloor != 0:
			input_dirX = 0
			input_dirY = 0
			shooting = 0
			onfloor = 1
			
			AnimationPlayer.stop()
			
			if holster == 1: #draw
				AnimationPlayer.play("draw")
				Sprite.set_texture(SPRITE1)
				Shadow.set_texture(SHADOW1)
				holster = 2
			elif holster == -1: #holster
				AnimationPlayer.play("holster")
				Sprite.set_texture(SPRITE2)
				Shadow.set_texture(SHADOW2)
				holster = -2
			else:
				holster /= 2
				if holster == 1: #cancel, holstered
					Sprite.set_texture(SPRITE2)
					Shadow.set_texture(SHADOW2)
				elif holster == -1: #cancel, drawn
					Sprite.set_texture(SPRITE1)
					Shadow.set_texture(SHADOW1)
		
		if holster == -1:
			if Input.is_action_pressed("ply_shoot"):
				if faketimer == 0:
					shoot()
					if ammo1 > 0:
						faketimer = 13
						ammo1 -= 1
					else:
						faketimer = 23
					
					shooting = 10
				
				#elif faketimer < 6:
				#	shooting = 0
				# arm lowering after every shot, worked well but didn't look good
			
			elif Input.is_action_just_released("ply_shoot"):
				if ammo1 < 1:
					faketimer /= 2
				
			elif !Input.is_action_pressed("ply_shoot"):
				if faketimer == 0:
					shooting = 0


		if onfloor != 0 && abs(holster) != 2:
			if Input.is_action_pressed("ply_sneak"):
				onfloor = 2
			else:
				onfloor = 1
			if Input.is_action_just_released("ply_sneak"):
				player_speed = SPEED
				
			if Input.is_action_just_pressed("ply_jump"):
				$Audio.JUMPa()
				motionZ = JUMP
				player_speed = SPEED/1.55
				onfloor = 0
		# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
		
		# walking #
		if input_dirX == -1 && blockX != -1:
			if position.x > (minX + 3):
				motion.x = -player_speed
			else:
				motion.x = 0
		elif input_dirX == 1 && blockX != 1:
			if position.x < (maxX - 27):
				motion.x = player_speed
			else:
				motion.x = 0
		else:
			motion.x = 0
		
		if input_dirY == -1 && blockY != -1:
			if position.y > maxY:
				motion.y = -player_speed
				#if input_dirX == 0:
				#	motion.x = 50
			else:
				motion.y = 0
		elif input_dirY == 1 && blockY != 1:
			if position.y < minY:
				motion.y = player_speed
				#if input_dirX == 0:
				#	motion.x = -50
			else:
				motion.y = 0
		else:
			motion.y = 0
		# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
		
		# animation player #
		if onfloor == 2:
			Sprite.frame = aniframe+shooting
			if input_dirX == 0 && input_dirY == 0:
				#if aniframe != 9: #Ducking frames: 7, 8, 9, 17, 18, 19, 27, 28, 29, 37, 38, 39
				#	AnimationPlayer.play("ducking")
				#else:
				AnimationPlayer.stop()
				aniframe = 9
			else:
				AnimationPlayer.play("sneak")
		elif onfloor == 0:
			Sprite.frame = aniframe+shooting
			AnimationPlayer.play("jump")
		else:
			if input_dirX == 0 && input_dirY == 0:
				if abs(holster) != 2:
					if shooting == 0:
						AnimationPlayer.play("idle") #AnimationPlayer.stop() #aniframe = 0
					else:
						AnimationPlayer.stop()
						aniframe = 0
			else:
				AnimationPlayer.play("walk")

		# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
		
		# aniframe logic #
		if onfloor == 1:
			if input_dirX == 0:
				if input_dirY == 1: #down
					Sprite.frame = aniframe+60+shooting
				elif input_dirY == -1: #up
					Sprite.frame = aniframe+80+shooting
				else: #idle
					Sprite.frame = aniframe+shooting
			else:
				if input_dirY == 1: #diag down
					Sprite.frame = aniframe+20+shooting
				elif input_dirY == -1: #diag up
					Sprite.frame = aniframe+40+shooting
				else: #side
					Sprite.frame = aniframe+shooting
		# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

var car
var drivepos = Vector2(0,0)

func driving():
	change_state(STATES.DRIVE)
	Shadow.visible = 0
	position = car.position
	Sprite.position = drivepos
	
	Col2D.scale.y = 0.5
	Col2D.position.y = -20
	
	if health < 1:
		die()
		change_state(STATES.IDLE)
	
	
#	if car.state == 0:
#		change_state(STATES.IDLE)
	
	if car.faceX != 0:
		face_dir = car.faceX
		
		if car.faceY == 0:
			Sprite.frame = 59 # -> sideways
			if car.faceX == 1:
				drivepos = Vector2(-6,-50)
			else:
				drivepos = Vector2(7,-49)
		else:
			if car.faceY == -1:
				Sprite.frame = 79 # ¨| diag-up
				if car.faceX == 1:
					drivepos = Vector2(-7,-55)
				else:
					drivepos = Vector2(-31,-53)
			if car.faceY == 1:
				Sprite.frame = 69 # _| diag-down
				if car.faceX == 1:
					drivepos = Vector2(-1,-55)
				else:
					drivepos = Vector2(25,-54)
		
	else:
		face_dir = 1
		if car.faceY == 1:
			Sprite.frame = 89 # \/ down
			drivepos = Vector2(14,-63)
		else:
			Sprite.frame = 99 # /\ up
			drivepos = Vector2(-19,-60)


export onready var ouch = 0

onready var health = 100

func take_damage(damage):
	health -= damage
	if health < 0:
		health = 0
	motion.x = 0
	motion.y = 0
	AnimationPlayer.play("hurt")
	if !Input.is_action_pressed("ply_sneak") && positionZ == 0:
		Sprite.frame = 107
	else:
		Sprite.frame = 106
	
	if abs(holster) > 1:
		holster /= 2
	
	# Sprite.frame = 107, ouch = 1 for (0.2 AniPlay X1), then ouch = 0

var clorotimer = 0

func take_cloroquina():
	health -= 3.5
	$Audio.PAINs()#PAINs()
	$Audio2.PAINs()#PAINs()
	
	if ammo1 == 0:
		faketimer = 23
	else:
		faketimer = 13
	
	if player_speed > 51: #If hit multiple times, get slower
		player_speed /= 2
		faketimer = round(faketimer*1.5)
	else:
		player_speed = 50
	
	clorotimer = 100
	
#	if Input.is_action_pressed("ply_sneak"):
#		Sprite.frame = 106
#		aniframe = 106
#	else:
#		Sprite.frame = 107
#		aniframe = 107

func set_flipped(flipstate):
	if flipstate: ### LEFT ###
		Sprite.flip_h = true
		Shadow.flip_h = true
	else: ########### RIGHT ###
		Sprite.flip_h = false
		Shadow.flip_h = false



####################################################################
####################################################################
####################################################################
####################################################################
####################################################################
####################################################################

const RECRUTO = preload("res://entities/recruto.tscn")
const DORTOR = preload("res://entities/dortor.tscn")
const CAR = preload("res://entities/car.tscn")
const NPCB = preload("res://entities/NPC-B.tscn")
const ZOMBIE = preload("res://entities/zombie.tscn")
const NPC = preload("res://entities/NPC.tscn")




var sight = INF
export var spawn_on = 0
export var spawn_frequency = 2000


var spawn_density = 0

var chosen_id = 0
var chosen
var chosen_position
var chosen_positionY
var chosen_direction = 1

func spawner():
	sight = abs(get_viewport().size.x)/2
	chosen_direction *= -1
	
	if spawn_on == 1:
		spawn_density = 1
		
		if chosen_id == 0:
			chosen = RECRUTO
		elif chosen_id == 1:
			chosen = DORTOR
		elif chosen_id == 2:
			chosen = CAR
		elif chosen_id == 3:
			chosen = NPCB
		elif chosen_id == 4:
			chosen = ZOMBIE
		elif chosen_id == 5:
			chosen = NPC
		
		chosen_id = (randi() % 6)
	
	elif spawn_on == 2:
		spawn_density = 1
		
		if chosen_id == 0:
			chosen = NPCB
		elif chosen_id == 1:
			chosen = NPCB
		elif chosen_id == 2:
			chosen = NPCB
		elif chosen_id == 3:
			chosen = DORTOR
		elif chosen_id == 4:
			chosen = DORTOR
		elif chosen_id == 5:
			chosen = RECRUTO
		elif chosen_id == 6:
			chosen = RECRUTO
		elif chosen_id == 7:
			chosen = CAR
		elif chosen_id == 8:
			chosen = CAR
		elif chosen_id == 9:
			chosen = ZOMBIE
		
		chosen_id = (randi() % 10)
	
	elif spawn_on == 3:
		spawn_density = 1
		
		if chosen_id == 0:
			chosen = NPCB
		elif chosen_id == 1:
			chosen = NPCB
		elif chosen_id == 2:
			chosen = NPCB#DORTOR
			
		chosen_id = (randi() % 3)
	
	elif spawn_on == 4:
		if chosen_id == 0:
			chosen = NPCB
			
			spawn_density = 1+(randi() % 5)
			
		elif chosen_id == 1:
			chosen = RECRUTO
			
			spawn_density = 2+(randi() % 3)
		
		elif chosen_id == 2:
			chosen = DORTOR
			
			spawn_density = 1+(randi() % 2)
		
		elif chosen_id == 3:
			chosen = CAR
			
			spawn_density = 1+(randi() % 2)
		
		chosen_id = (randi() % 4)
	
	spawn_guy()




func spawn_guy():
	var dude_instance = chosen.instance()
	
	dude_instance.maxX = maxX
	dude_instance.minX = minX
	dude_instance.maxY = maxY
	dude_instance.minY = minY
	
	if position.x < minX + sight:
		chosen_position = minX + (sight*2)
		
	elif position.x > maxX - sight:
		chosen_position = maxX - (sight*2)
		
	else:
		chosen_position = position.x+(sight*chosen_direction)
	
	
	
	
	
	if lane1 != 0 && lane2 != 0:
		chosen_positionY = (randi() % 50)
		
		if chosen_positionY % 2 == 0:
			dude_instance.position.y = lane1-(chosen_positionY+50)
		else:
			dude_instance.position.y = lane2+chosen_positionY
	else:
		chosen_positionY = maxY+(randi() % (maxY-minY))
	
	
	
	
	if chosen == CAR:#chosen_id == 2:
		dude_instance.position.x = (chosen_position*2)*chosen_direction
		if chosen_direction == 1:
			dude_instance.position.y = lane1
		else:
			dude_instance.position.y = lane2
		
		dude_instance.faceX = -chosen_direction
		dude_instance.neutral_dir = -chosen_direction
		dude_instance.state = 3
	else:
		dude_instance.position.x = (chosen_position+(10*zoom)+chosen_positionY)*chosen_direction
	
	
	if chosen_direction == 1:
		chosen_direction = -1
	elif chosen_direction == -1:
		chosen_direction = 1
	
	
	get_parent().add_child(dude_instance)
	
	if spawn_density != 0:
		spawn_density -= 1
		spawn_guy()
		
		
	
	
