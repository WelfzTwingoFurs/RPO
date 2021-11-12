extends KinematicBody2D
var motion = Vector2()
var dirX = 1
var dirY = 0

var accel = 330
var posZcurrent = 48

var shadow_pos = 0
var posZ = 48

# 0=shot back, 1=enemy
var who_owner = 0

func _ready():
	$AnimationPlayer.play("spin")
	
	if abs(dirX) == 1:
		$Sprite.scale.x = dirX
		$Shadow.scale.x = dirX

	$Area2D.position.y -= posZ
	
	posZcurrent = round($Area2D.position.y)
	
#	Global.point_of_interest = position 
#	Global.interest_type = 1

var rate = 0.01

func _physics_process(_delta):
	motion = move_and_slide(motion, Vector2(0,-1))
	
	$Shadow.frame = $Sprite.frame
	
	accel = lerp(accel,170,0.02)
	
	motion.x = accel*dirX
	motion.y = accel*dirY
	
	rate += 0.0001
	posZcurrent = lerp(posZcurrent,0,rate)
	
	$AnimationPlayer.playback_speed = accel/300
	
	$Sprite.position.y = posZcurrent
	$Area2D.position.y = posZcurrent
	
	if posZcurrent > -10:
		queue_free()
	
	for body in damagearray:
		if body.is_in_group("player"):
			body.take_cloroquina()
			queue_free()
		elif body.is_in_group("amigo"):
			#var damage
			body.take_cloroquina()#take_damage(damage)
			queue_free()
		elif body.is_in_group("dortor"):
			#var damage
			#take_damage(damage)
			if body.playeranger == 0:
				body.take_cloroquina()
				queue_free()

var damagearray = []
var bodyY

func _on_Area2D_body_entered(body):
	bodyY = -(body.position.y - position.y)
	if bodyY > 10:
#		if bodyY < 69:
		if !damagearray.has(body):
			damagearray.push_back(body)

func _on_Area2D_body_exited(body):
	if damagearray.has(body):
		damagearray.erase(body)
