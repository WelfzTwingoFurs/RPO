extends KinematicBody2D

# This needs to be replaced by NPC-B completely. Add a single variation and exceptions, and their development will be synced


var motion = Vector2()
var speed = 90

onready var Sprite = $Sprite
onready var Shadow = $Shadow
onready var AniPlay = $AniPlay
onready var Col2D = $Col2D
#onready var Audio = $Audio

enum STATES {IDLE,FEAR}
export(int) var state = STATES.IDLE

export var minX = 0
export var maxX = 0
# These will be set on startup, and re-adjusted by RayCast2D's in the levels
export var minY = 0
export var maxY = 0

var blockX = 0
var blockY = 0

var face_dir = 1

export var fear = 0





func change_state(new_state):
	state = new_state


var ready_delay = 0

func _ready():
	ready_delay = (randi() % 9) + 2 #so it's not 0 or 1
	
	target = Vector2(INF,INF)
	
	Global.npcs += 1



var system_msecs = 0

func _process(_delta):
	if position.y < maxY:# && blockY == 0: ##246
		position.y += 1
		
	elif position.y > minY:
		position.y -= 1
	
	
	motion = move_and_slide(motion, Vector2(0,-1))
	
	match state:
		STATES.IDLE:
			idle()
		STATES.FEAR:
			fearing()
	
	if face_dir == 1:
		set_flipped(false)
	elif face_dir == -1:
		set_flipped(true)
	
	
	Shadow.frame = Sprite.frame
	
	system_msecs = OS.get_system_time_secs()
	
	self.z_index = (position.y/10)-1
	
	if (system_msecs % 5) == 0:
		var sight = abs(get_viewport().size.x)/2
		
		
		if Global.player.position.x < minX + sight:
			if position.x > minX + (sight*2):
				queue_freedom()
		
		elif Global.player.position.x > maxX - sight:
			if position.x < maxX - (sight*2):
				queue_freedom()
		
		else:
			if abs(Global.player.position.x - position.x) > sight:
				queue_freedom()

func queue_freedom():
	Global.npcs -= 1
	queue_free()

var msecs_lock #use like this:
#	if msecs_lock != system_msecs:
#		msecs_lock = system_msecs


var target = Vector2(INF,INF)

var focus_var = 1

var wait = 0

func idle():
	#$Label.text = str(ready_delay,"=delay \n",focus_var,"=focus \n",dortors_in_scene,"\n",target,"=target \n",entity_check,"=check1")
	
	if wait == 0:
		if target == null:
			if (system_msecs % ready_delay*100) == 0:
				if msecs_lock != system_msecs:
					msecs_lock = system_msecs
					pick_idle_anim()
					no_target_wandering()
			
		else:
			if focus_var > 0:
				if msecs_lock != system_msecs:
					msecs_lock = system_msecs
					focus_var -= 1
				
				
				if abs(target.x - position.x) < ready_delay*10:
					pick_idle_no_randi()
					
					
				else:
					face_dir = sign(target.x - position.x)
					motion.x = speed*face_dir
					motion.y = speed/2*sign(target.y - position.y)
					AniPlay.play("walk")
				
				
	#			if target.y - position.y < ready_delay*4:
	#				motion.y = speed*sign(target.y - position.y)
	#				
	#			else:
	#				motion.y = 0#speed*sign(target.y)
				
				
				
			elif focus_var == 0:
				focus_var = -1
				target = Vector2(0,0) #Clear target before checking, else old deleted targets, if were closer, wouldn't clear otherwise, as they stop existing
				pick_idle_anim() #motion = 0
				no_target_wandering()
			else: #smaller than 0
				if (system_msecs % ready_delay) == 0:
					focus_var = (randi() % 10)
	else:
		Sprite.frame = 0
		motion.x = 0
		motion.y = 0
	
	if fear != 0:
		change_state(STATES.FEAR)

# jo's code
#var closest_body
#var closest_dist = INF
#for body in bodies:
#  var dist = body.position.distance_to(player.position)
#  if dist < closest_dist:
#    closest_body = body
#    closest_dist = dist


var entity_check




func null_search(_item):
#	dortors_in_scene.erase(item)
	entity_check = null
	no_target_wandering() #target RESET



func no_target_wandering():
	var pick_destiny = (randi() % 6)
	
	if pick_destiny == 0:
		target = Vector2(minX,position.y)
	elif pick_destiny == 1:
		target = Vector2(maxX,position.y)
	
	elif pick_destiny == 2:
		target = Vector2(minX,minY)
	elif pick_destiny == 3:
		target = Vector2(maxX,maxY)
	
	elif pick_destiny == 4:
		target = Vector2(maxX,minY)
	elif pick_destiny == 5:
		target = Vector2(minY,maxY)


var pick_idle = 0

func pick_idle_anim():
	motion.x = 0
	motion.y = 0
	
	pick_idle = (randi() % 4)
	if pick_idle == 0:
		AniPlay.play("idle1")
		
	elif pick_idle == 1:
		AniPlay.stop()
		Sprite.frame = 3
		
	elif pick_idle == 2:
		AniPlay.play("idle2")
		
	elif pick_idle == 3:
		AniPlay.stop()
		Sprite.frame = 4



func pick_idle_no_randi():
	motion.x = 0
	motion.y = 0
	AniPlay.stop()
	
	if pick_idle == 0:
		Sprite.frame = 1
		
	elif pick_idle == 1:
		Sprite.frame = 3
		
	elif pick_idle == 2:
		Sprite.frame = 4
		
	elif pick_idle == 3:
		Sprite.frame = 8


func fearing():
	if fear == -1:
		motion.x = speed*face_dir
		AniPlay.play("prun")
	elif fear == 1:
		motion.x = 2*speed*face_dir
		AniPlay.play("run")



func set_flipped(flipstate):
	if flipstate: ### LEFT ### -1
		Sprite.flip_h = true
		Shadow.flip_h = true
	else: ########### RIGHT ### 1
		Sprite.flip_h = false
		Shadow.flip_h = false



func cloroquina(dortor_dad):
	var cloroman = load("res://entities/zombie.tscn")
	var cloro_instance = cloroman.instance()
	
	cloro_instance.position = position
	cloro_instance.face_dir = face_dir
	cloro_instance.dortor = dortor_dad
	
	cloro_instance.minX = minX
	cloro_instance.minY = minY
	cloro_instance.maxX = maxX
	cloro_instance.maxY = maxY
	
	get_parent().add_child(cloro_instance)
	Global.npcs -= 1
	queue_free()


