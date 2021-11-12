extends KinematicBody2D

var motion = Vector2()
var speed = 90

onready var Sprite = $Sprite
onready var Shadow = $Shadow
onready var AniPlay = $AniPlay
onready var Col2D = $Col2D
onready var Audio = $Audio

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


export var npcb = -1



func change_state(new_state):
	state = new_state


const b1 = preload("res://media/NPCB-hobo.png")
const b1s = preload("res://media/NPCB-hobo_shadow.png")

const a1 = preload("res://media/NPC-Hoodie2.png")
const a1s = preload("res://media/NPC-Hoodie_shadow.png")

var ready_delay = 0

func _ready():
	if npcb == -1:
		npcb = 1#(randi() % 2) #0 or 1
	
	if npcb == 0:
		Sprite.texture = a1
		Shadow.texture = a1s
	elif npcb == 1:
		Sprite.texture = b1
		Shadow.texture = b1s
	
	
	
	if minX == 0:
		minX = Global.minX
	if maxX == 0:
		maxX = Global.maxX
	if minY == 0:
		minY = Global.minY
	if maxY == 0:
		maxY = Global.maxY
	
	
	ready_delay = (randi() % 9) + 2 #so it's not 0 or 1
	
	dortor_target = Vector2(INF,INF)
	
	Global.npcs += 1


var point_of_interest = Vector2(INF,INF)
var interest_type

var system_secs = 0

func _process(_delta):
	$Label.text = str(self)
	
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
	
	if npcb == 1:
		for item in dortors_in_scene:
			var wr = weakref(item)
			if (!wr.get_ref()):
				dortor_lookfor()
	
	
	Shadow.frame = Sprite.frame
	
	system_secs = OS.get_system_time_secs()
	
	self.z_index = (position.y/10)-1
	
	if (system_secs % 5) == 0:
		sight = abs(get_viewport().size.x)/2
		
		
		if Global.player.position.x < minX + sight:
			if position.x > minX + (sight*2):
				queue_freedom()
		
		elif Global.player.position.x > maxX - sight:
			if position.x < maxX - (sight*2):
				queue_freedom()
		
		else:
			if abs(Global.player.position.x - position.x) > sight:
				queue_freedom()
	
	
	interest_type = Global.interest_type
	point_of_interest = Global.point_of_interest 
	
	if my_point.x == point_of_interest.x:
		if system_secs > (my_point_secs+2):
			Global.interest_type = 0

func queue_freedom():
	Global.npcs -= 1
	queue_free()

var msecs_lock #use like this:
#	if msecs_lock != system_secs:
#		msecs_lock = system_secs

var dortors_in_scene = []
var dortor_target = Vector2(INF,INF)

var focus_var = 1

var wait = 0

func idle():
	#$Label.text = str(ready_delay,"=delay \n",focus_var,"=focus \n",dortors_in_scene,"\n",dortor_target,"=target \n",entity_check,"=check1")
	
	if fear == 0:
		if my_point.x != point_of_interest.x:
			if interest_type != 0:
				#point_of_interest = Global.point_of_interest 
				sight = abs(get_viewport().size.x)/2
				
				
				
				if abs(point_of_interest.x - position.x) < (sight/4):
					face_dir = -sign(point_of_interest.x - position.x)
					
					npc_scream()
					fear = 1
					change_state(STATES.FEAR)
				
				else:#if point_of_interest.x > (sight/2):
					face_dir = sign(point_of_interest.x - position.x)
					dortor_target.x = position.x
					focus_var = 10
					
					
					
					#if abs(point_of_interest.y - position.y) < 20:

					if point_of_interest.y != INF:
						if abs(point_of_interest.y - position.y) < 20:
							
							if point_of_interest.y < position.y: #HIGHER
								dortor_target.y = position.y+20
							else:
								dortor_target.y = position.y-20

					else:
						dortor_target.y = position.y
					
					
					if dortor_target.y < maxY:
						dortor_target.y = maxY+10
					elif dortor_target.y > minY:
						dortor_target.y = minY-10
	
	
	
	
	
	
	if wait == 0:
		if dortor_target == null:
			if (system_secs % ready_delay*100) == 0:
				if msecs_lock != system_secs:
					msecs_lock = system_secs
					pick_idle_anim()
					if npcb == 1:
						dortor_lookfor()
			
		else:
			if focus_var > 0:
				if msecs_lock != system_secs:
					msecs_lock = system_secs
					focus_var -= 1
				
				
				if abs(dortor_target.x - position.x) < ready_delay*10 && abs(dortor_target.y - position.y) < 1:
					#motion.x = 0
					#if abs(dortor_target.y - position.y) < 1:
					pick_idle_no_randi()
					#else:
					#	motion.y = speed*sign(dortor_target.y - position.y)
					
					if npcb == 1:
						if msecs_lock != system_secs:
							msecs_lock = system_secs
							dortor_lookfor()
						#pick_idle_anim()
					
				else:
					AniPlay.play("walk")
					
					motion.y = speed/2*sign(dortor_target.y - position.y)
					
					if abs(dortor_target.x - position.x) > ready_delay*10:
						face_dir = sign(dortor_target.x - position.x)
						
						motion.x = speed*face_dir
				
				#if position.y != dortor_target.y:
				#	motion.y = speed*sign(dortor_target.y - position.y)
				#	motion.x /= 2
				#	AniPlay.play("walk")
				
				
	#			if dortor_target.y - position.y < ready_delay*4:
	#				motion.y = speed*sign(dortor_target.y - position.y)
	#				
	#			else:
	#				motion.y = 0#speed*sign(dortor_target.y)
				
				
				
			elif focus_var == 0:
				focus_var = -1
				dortor_target = Vector2(0,0) #Clear target before checking, else old deleted targets, if were closer, wouldn't clear otherwise, as they stop existing
				pick_idle_anim() #motion = 0
				if npcb == 1:
					dortor_lookfor()
			else: #smaller than 0
				if (system_secs % ready_delay) == 0:
					focus_var = (randi() % 10)
	else:
		Sprite.frame = 0
		motion.x = 0
		motion.y = 0
	
	
	if Global.player.holster == -1:
		sight2 = abs(get_viewport().size.x)/6
		
		if abs(position.x - Global.player.position.x) < sight2 && abs(position.y - Global.player.position.y) < 40:
			
			
			
			if -sign(position.x - Global.player.position.x) != Global.player.face_dir:
				if Global.player.face_dir != face_dir:
					motion.x = 0
					motion.y = 0
					
					if wait != 0:
						fear = -1
					else:
						fear = 2
	
	
	
	if fear != 0:
		AniPlay.play("fear")
		change_state(STATES.FEAR)
	
	

# jo's code
#var closest_body
#var closest_dist = INF
#for body in bodies:
#  var dist = body.position.distance_to(player.position)
#  if dist < closest_dist:
#    closest_body = body
#    closest_dist = dist

func fearing():
	if fear != 1:
		if Global.player.shooting != 0:
			face_dir = sign(position.x - Global.player.position.x)
			fear = 1
			npc_scream()
	
	if fear == -1:
		motion.x = speed*face_dir
		AniPlay.play("prun")
	elif fear == 1:
		motion.x = 2*speed*face_dir
		AniPlay.play("run")
	
	
	elif fear == 2:
		if Global.player.holster == 1:
			AniPlay.play("defear")
			
		else:
			if -sign(position.x - Global.player.position.x) != face_dir:
				AniPlay.play("defear")
				no_target_wandering()
				
			
			else:
				if Global.player.face_dir == face_dir:
					AniPlay.play("prunPlayer")
		
		
	elif fear == -2:
		face_dir = sign(position.x - Global.player.position.x)
		motion.x = speed*face_dir
		
		if Global.player.face_dir == face_dir:
			motion.x = 0
			motion.y = 0
			
			AniPlay.play("fear")
			Sprite.frame = 19
			face_dir = -sign(position.x - Global.player.position.x)
			fear = 2

var sight
var sight2

func runawayor():
	sight2 = abs(get_viewport().size.x)/8
	if abs(position.x - Global.player.position.x) < sight2:
		npc_scream()
		face_dir = sign(position.x - Global.player.position.x)
		fear = 1
	else:
		motion.x = 0
		motion.y = 0
		fear = 2
		#AniPlay.play("defear")

var entity_check

func dortor_lookfor():
	dortors_in_scene = get_tree().get_nodes_in_group("dortor")
	
	if dortors_in_scene.size() != 0:
		for item in dortors_in_scene:
			var wr = weakref(item) # wr is not consistent, but item is, and so is entity_check
			if (wr.get_ref()): #Check if it exists, if not, null_search()
				if item != entity_check: #If not the same as first time
					#print("check is not ",wr)
					if abs(item.position.x - position.x) < abs(dortor_target.x - position.x):
						#print("NEW TARGET ",wr) 
						dortor_target = Vector2(item.position)
						entity_check = item #and lock 
				else: #, if target still the same
					dortor_target = Vector2(item.position)
			else:
				null_search(item) 
	else:
		no_target_wandering() #DORTOR_TARGET RESET




func null_search(_item):
#	dortors_in_scene.erase(item)
	entity_check = null
	no_target_wandering() #DORTOR_TARGET RESET



func no_target_wandering():
	
	
	if Global.lane1 != 0:# && Global.lane2 != 0:
		if position.y < Global.lane1:
			var pick_destiny = (randi() % 6)
			
			if pick_destiny == 0:
				dortor_target = Vector2(minX,position.y)
			elif pick_destiny == 1:
				dortor_target = Vector2(maxX,position.y)
			elif pick_destiny == 2:
				dortor_target = Vector2(maxX,maxY)
			elif pick_destiny == 3:
				dortor_target = Vector2(minY,maxY)
			elif pick_destiny == 4:
				dortor_target = Vector2(maxX,Global.lane1-40)
			elif pick_destiny == 5:
				dortor_target = Vector2(minY,Global.lane1-40)
		
		
		elif position.y < Global.lane2:
			var pick_destiny = (randi() % 2)
			
			if pick_destiny == 0:
				dortor_target = Vector2(minX,Global.lane1-40)
			elif pick_destiny == 1:
				dortor_target = Vector2(maxX,Global.minY)
		
		else:
			var pick_destiny = (randi() % 2)
			
			if pick_destiny == 0:
				dortor_target = Vector2(minX,minY)
			elif pick_destiny == 1:
				dortor_target = Vector2(maxX,minY)
		
	else:#if position.y > lane2:
		var pick_destiny = (randi() % 6)
		
		if pick_destiny == 0:
			dortor_target = Vector2(minX,position.y)
		elif pick_destiny == 1:
			dortor_target = Vector2(maxX,position.y)
		
		elif pick_destiny == 2:
			dortor_target = Vector2(minX,minY)
		elif pick_destiny == 3:
			dortor_target = Vector2(maxX,maxY)
		
		elif pick_destiny == 4:
			dortor_target = Vector2(maxX,minY)
		elif pick_destiny == 5:
			dortor_target = Vector2(minY,maxY)
	
	
	
	if dortor_target.y == maxY:
		dortor_target.y -= ready_delay*2
	elif dortor_target.y == minY:
		dortor_target.y += ready_delay*2


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






func set_flipped(flipstate):
	if flipstate: ### LEFT ### -1
		Sprite.flip_h = true
		Shadow.flip_h = true
	else: ########### RIGHT ### 1
		Sprite.flip_h = false
		Shadow.flip_h = false


var dortor_dad

func cloroquina(dortor_dad):
	if npcb == 1:
		var cloroman = load("res://entities/zombie.tscn")
		var cloro_instance = cloroman.instance()
		
		cloro_instance.position = position
		cloro_instance.face_dir = face_dir
		cloro_instance.dortor_dad = dortor_dad
		
		cloro_instance.npcb_was = npcb
		
		cloro_instance.minX = minX
		cloro_instance.minY = minY
		cloro_instance.maxX = maxX
		cloro_instance.maxY = maxY
		
		get_parent().add_child(cloro_instance)
		Global.npcs -= 1
		queue_free()

var my_point = Vector2(INF,INF)
var my_point_secs = 0

func npc_scream():
	Audio.npc_scream()
	my_point_secs = system_secs
	my_point = position
	Global.point_of_interest = position 
	Global.interest_type = 3
