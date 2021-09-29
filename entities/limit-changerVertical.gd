extends RayCast2D

export var minX = -1
export var maxX = -1
# These will be set here, and exported to entities on touch
export var minY = -1
export var maxY = -1

# Default:
# minX = 0
# maxX = 2900
# minY = 460
# maxY = 246

export var motdir = 0

func _process(delta):
	if is_colliding():
		var who = get_collider()
		
		if who != null:
			if who.is_in_group("player"):
				if who.input_dirX == motdir:
					updatem(who)
			
			elif who.is_in_group("enemy"):
				if who.is_in_group("dortor"):
					if who.face_dir == -motdir:
						updatem(who)
				else:
					if who.face_dir == motdir:
						updatem(who)
			
			else:#if who.is_in_group("bullet"):   #BulletArea2D
				if who.get_name() == "BulletArea2D":
					if who.direction == motdir:
						updatem_BULLET(who)
				
				elif who.get_name() == "Area2DSolid":
					if who.motion_dirX == motdir:
						updatem(who)

#			else:
#				if who.get_name() == "nome enorme": #This doesn't work because clones entities get a number in their name
#					pass #maybe ussing get_node and then asking the name might work

func updatem(who):
	if minX != -1:
		who.minX = minX
	if maxX != -1:
		who.maxX = maxX
	if minY != -1:
		who.minY = minY
	if maxY != -1:
		who.maxY = maxY
	
	
	if who.position.y < maxY-1:
		who.blockX = motdir
		
	elif who.position.y > minY+1:
		who.blockX = motdir
	else:
		who.blockX = 0

func updatem_BULLET(who):
	if minX != -1:
		who.minX = minX
	if maxX != -1:
		who.maxX = maxX
	if minY != -1:
		who.minY = minY+65#+49 is correct, but higher makes for better shooting simply
	if maxY != -1:
		who.maxY = maxY+49
	
	
#	if who.position.y < maxY-49:
#		who.queue_free_us_all()
#
#	elif who.position.y > minY+49:
#		who.queue_free_us_all()



