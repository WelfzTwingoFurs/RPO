extends AudioStreamPlayer2D
onready var Audio = $Audio


#const STEP1 = pre
func STEP1a():
	Audio.stream = load("res://media/sons/step1.wav")
	Audio.play()

#const STEP2 = pre
func STEP2a():
	Audio.stream = load("res://media/sons/step2.wav")
	Audio.play()

#const STEP3 = pre
func STEP3a():
	Audio.stream = load("res://media/sons/step3.wav")
	Audio.play()

#const STEP4 = pre
func STEP4a():
	Audio.stream = load("res://media/sons/step4.wav")
	Audio.play()

#const JUMP = pre
func JUMPa():
	Audio.stream = load("res://media/sons/jump.wav")
	Audio.play()

#const LAND = pre
func LANDa():
	Audio.stream = load("res://media/sons/land.wav")
	Audio.play()

#const PAIN1 = pre
func PAIN1a():
	Audio.stream = load("res://media/sons/ply_pain.wav")
	Audio.play()

#const PAIN2 = pre
func PAIN2a():
	Audio.stream = load("res://media/sons/ply_pain2.wav")
	Audio.play()

#const DIE = pre
func DIEa():
	Audio.stream = load("res://media/sons/ply_die.wav")
	Audio.play()


#this is just a backup place, delete it later
#
#	colR = sin((OS.get_system_time_msecs() * 20 ) / (1000 / 2*PI))# * (steps / steps)
#				# consistent random #
#	colG = sin((OS.get_system_time_msecs() * 20 ) / (1000 / 2*PI) + ((PI * 2) / 3))# * (steps / steps)
#													# smoothened #
#	colB = sin((OS.get_system_time_msecs() * 20 ) / (1000 / 2*PI) + ((PI * 4) / 3))# * (steps / steps)
#																					# value variation #
#
#
#
#
#
#
#
#
#
#func shoot():
#	ammo1 -= 1
#	var bul_instance = bul_entity.instance()
#	bul_instance.direction = face_dir
#	bul_instance.position = position+Vector2((20*face_dir),positionZ-17)
#	bul_instance.shadow_pos = positionZ-63
#	get_parent().add_child(bul_instance)
#
#func _ready():
#	motion.x = SPEED * direction
#	$Sprite.scale.x = direction
#	$Shadow.position.y = -shadow_pos
#
#
#
#
#
#
#		if sneak == 0:
#			if input_dirY == -1:
#				AnimationPlayer.play("walkdiagup")
#			elif input_dirY == 1:
#				AnimationPlayer.play("walkdiagdown")
#			else:
#				AnimationPlayer.play("walk")
#		else:
#			AnimationPlayer.play("sneak")
#
#
#
#
#
#
#
#
#
#		if sneak == 0:
#			if input_dirY == -1:
#				AnimationPlayer.play("walkdiagup")
#			elif input_dirY == 1:
#				AnimationPlayer.play("walkdiagdown")
#			else:
#				AnimationPlayer.play("walk")
#		else:
#			AnimationPlayer.play("sneak")
#	else:
#		motion.x = 0
#
#
#		if sneak == 0:
#			if input_dirY == -1:
#				AnimationPlayer.play("walkup")
#			elif input_dirY == 1:
#				AnimationPlayer.play("walkdown")
#			else:
#					AnimationPlayer.stop()
#					if sneak == 0:
#						aniframe = 0
#					else:
#						aniframe = 7
#		else:
#			if input_dirY != 0:
#				AnimationPlayer.play("sneak")
#			else:
#				aniframe = 7
#
#	if input_dirY != 0:
#		if position.y > minY:
#			walk = 1
#		if position.y < maxY:
#			walk = 1
#
#	else:
#		motion.y = 0
#		if input_dirX == 0:
#			AnimationPlayer.stop()
#			if sneak == 0:
#				aniframe = 0
#			else:
#				aniframe = 9
#
#
