extends KinematicBody2D

var direction = 1
export var speed = 500
var motion = Vector2()

var shadow_pos = 0
var posZ = 0

# 0=player, 1=enemy
var who_owner = 0

var minX = 0
var maxX = 973

const alt1 = preload("res://media/bullet2.png")
const alt2 = preload("res://media/bullet3.png")

func _ready():
	if who_owner == 1:
		$Sprite.texture = alt2
		$Shadow.texture = alt2
	
	minX = Global.minX
	maxX = Global.maxX
	
	motion.x = speed * direction
	$Sprite.scale.x = direction
	$Sprite.position.y += posZ
	$Area2D.position.y += posZ


var colR = 0
var colG = 0
var colB = 0
#var steps = 2
var supernumbers
var meganumbers

var playerY

func _process(delta):
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
#				if !damagearray.has(body):
#					damagearray.push_back(body)

	else: # enemy shot
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
