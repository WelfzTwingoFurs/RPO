extends KinematicBody2D

onready var bullshit2D = $BulletArea2D

var direction = 1
export var speed = 500
var motion = Vector2()

var shadow_pos = 0
var posZ = 0

# 0=player, 1=enemy
var who_owner = 0

export var minX = -9999
export var maxX = 9999
export var minY = 9999
export var maxY = -9999

const alt1 = preload("res://media/bullet2.png")
const alt2 = preload("res://media/bullet3.png")

func _ready():
	if who_owner == 1:
		$Sprite.texture = alt2
	#	$Shadow.texture = alt2
	
	motion.x = speed * direction
	$Sprite.scale.x = direction
	$Sprite.position.y += posZ
	$BulletArea2D.position.y += posZ
	
	bullshit2D.minX = minX
	bullshit2D.maxX = maxX
	bullshit2D.minY = minY
	bullshit2D.maxY = maxY
	bullshit2D.direction = direction

var colR = 0
var colG = 0
var colB = 0
#var steps = 2
var supernumbers
var meganumbers

var playerY

func _process(delta):
	minX = bullshit2D.minX
	maxX = bullshit2D.maxX
	minY = bullshit2D.minY
	maxY = bullshit2D.maxY
	
#	print(round(position.y))
#	print(minY,"v ^",maxY)
	
	if position.y < maxY:
		queue_free()
		
	if position.y > minY:
		queue_free()
	
	supernumbers = sin((OS.get_system_time_msecs() / 50 ))
	meganumbers = sin(OS.get_system_time_secs())
	
	colR = abs(supernumbers)
	colG = abs(supernumbers + meganumbers)
	colB = colR + meganumbers
	
	$Sprite.set_modulate(Color(colR,colG,colB))

	motion = move_and_slide(motion, Vector2(0,-1))
	
#	playerY = position.y - Global.player.position.y
	self.z_index = round(position.y/10)#+posZ
	
	if position.x < minX-45:
		queue_free()
	elif position.x > maxX+45:
		queue_free()
	
	
	


	for body in damagearray:
		body.take_damage(damage)
		queue_free()
		
		# play blood effect and queue_Free

var damage = 15

var damagearray = []

########### for body in damagearr: #############



var bodyY

func _on_Area2D_body_entered(body):
	
	if who_owner == 0: # player shot
		if body.is_in_group("enemy"):
			bodyY = -(body.position.y - position.y)
#			if bodyY > 25:
			if bodyY < 76:
				body.take_damage(damage)
				queue_free()
				
				Global.player.score += 500
#				if !damagearray.has(body):
#					damagearray.push_back(body)

	else: # enemy shot
		if body.get_name() != "GroundCol":
			if body.is_in_group("player") or body.is_in_group("amigo"):
				bodyY = -(body.position.y - position.y)
				if bodyY > 35:
					if bodyY < 69:
						body.take_damage(damage)
						queue_free()
	#					if !damagearray.has(body):
	#						damagearray.push_back(body)

func _on_Area2D_body_exited(body):
	if damagearray.has(body):
		damagearray.erase(body)




#	print("^",maxY," v",minY)

#func _on_Area2D_area_entered(area):
#	if area.is_in_group("limit-changer"):
#		$bullshit2D.disabled = 0
#		if area.minX != -1:
#			minX = area.minX
#		if area.maxX != -1:
#			maxX = area.maxX
#		if area.minY != -1:
#			minY = area.minY
#		if area.maxY != -1:
#			maxY = area.maxY
#
#
#func _on_Area2D_area_exited(area):
#	$bullshit2D.disabled = 1
