extends KinematicBody2D

onready var Audio = $Audio

var motion = Vector2()

var shadow_pos = 0
var posZ = -48


var minX = 0
var maxX = 973

var minY = 460
var maxY = 0
var radar_icon = "can"

func _ready():
	$Sprite.position.y += posZ
	$Area2D.position.y += posZ
	
	minX = Global.minX
	maxX = Global.maxX
	
	minY = Global.minY
	maxY = Global.maxY
	
	$Sprite.frame = type
	$Shadow.frame = type
	
	if type == 0:
		radar_icon = "bullet"
	elif type == 1:
		radar_icon = "money"
	elif type == 2:
		radar_icon = "cloro"
	elif type == 3:
		radar_icon = "can"
		
		
		
		
		
		
export var type = 0
# 0 = ammo1
# 1 = money200
# 2 = cloroquinaBox
# 3 = moçaCan
# ...

func _process(delta):
	motion = move_and_slide(motion, Vector2(0,-1))
	
	if position.x < minX-45:
		queue_free()
	elif position.x > maxX+45:
		queue_free()
	
	$Sprite.position.y = posZ
	$Area2D.position.y = posZ
	
	if posZ < 0:
		posZ += 0.3
	
	for body in getterarray:
		player = body
		bodyY = -(body.position.y - position.y)
		
		if bodyY > 5 && body.positionZ == 0:
			if body.itembusy == 0:
				#if player 1: var something go right instead sk8r
				gotten = 1
				$Shadow.visible = 0
				
				if type == 0: #ammo
					body.Audio3.ammo1get()
					if body.Audio.is_playing():
						body.Audio2.ammo1get()
					else:
						body.Audio.ammo1get()
				
				elif type == 1: #money
					body.Audio3.moneyget()
#					if body.Audio.is_playing():
#						body.Audio2.moneyget()
#					elif !body.Audio2.is_playing():
#						body.Audio.moneyget()
				
				elif type == 2:
					body.Audio3.cloroget()
#					if body.Audio.is_playing():
#						body.Audio2.cloroget()
#					elif !body.Audio2.is_playing():
#						body.Audio.cloroget()
				
				elif type == 3:
					body.Audio3.canget()
#					if body.Audio.is_playing():
#						body.Audio2.canget()
#					elif !body.Audio2.is_playing():
#						body.Audio.canget()
					
				
				if body.itembusy == 0:
					body.itembusy = 1
	
	if gotten != 0:
		begot()
		self.z_index = 100
	else:
		self.z_index = round(position.y/10)-4#+posZ

var gotten = 0

var player

func begot():
	radar_icon = "nothing"
	motion.x -= 6
	motion.y += 6
	posZ += 0.2
	
	if position.y > minY:
		#if player etc
		if player.itembusy == 1:
			player.itembusy = 0
		
		if type == 0:
			if player.ammo1 > 84:
				player.ammo1 = 99
			else:
				player.ammo1 += 15
		if type == 1:
			player.moneys += 1
		elif type == 2:
			player.cloros += 1
		elif type == 3:
			player.cans += 1
		
		
		Global.player.score += 200
		queue_free()

var bodyY
var getterarray = []



func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		if !getterarray.has(body):
			getterarray.push_back(body)


func _on_Area2D_body_exited(body):
	if gotten == 0:
		if getterarray.has(body):
			getterarray.erase(body)

#func shoot():
#	$Audio2.SHOOTs()
#	var bul_instance = bul_entity.instance()
#	bul_instance.direction = face_dir
#	bul_instance.who_owner = 0
#	bul_instance.position = position+Vector2((30*face_dir),(48))
#	bul_instance.posZ = (positionZ-67)+bul_pos #positionZ-67-bul_pos
#	get_parent().add_child(bul_instance)
