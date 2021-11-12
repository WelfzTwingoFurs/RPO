extends KinematicBody2D

var radar_icon = "dortor"

var motion = Vector2()
var speed = 130

onready var Sprite = $Sprite
onready var Shadow = $Shadow
onready var AniPlay = $AniPlay
onready var Col2D = $Col2D
onready var Audio = $Audio
onready var DealCol = $Lazy2D/DealCol

enum STATES {IDLE,DOORSPAWN,ENGAGE,SHOOTING,OUCH,GIVEUP,NPCB_ENGAGE}
export(int) var state = STATES.DOORSPAWN

var minX = 0
var maxX = 973
# These will be set in-level, exported to global, then imported to entities.
var minY = 350
var maxY = 246

var blockX = 0
var blockY = 0


var howmany


var faketimer = 1
var timerstep = 1
var timervalues = [80,91,102,113,154,45,66]
var wasfaketimer = 1
#timerstep = (randi() % 7) #between 0 and 6
#faketimer = timervalues[timerstep]


var sight = 0


var player

var playerX = 46
var playerY = 16


var system_msecs

var face_dir = -1

export var giveup = 0

var bulletY = 0

var type

const alt1 = preload("res://media/dortor-defaultish.png")
const alt2 = preload("res://media/dortor-havan2.png")
const alt3 = preload("res://media/dortor-gman3.png")
const alt4 = preload("res://media/dortor-badds2.png")

const BUL_ENTITY = preload("res://entities/bullet-dortor.tscn")

func change_state(new_state):
	state = new_state


func _ready():
	timerstep = (randi() % 7)
	
	Global.foes += 1
	
	howmany = Global.foes
	
	if howmany == 0:
		howmany = 1
	
	minX = Global.minX
	maxX = Global.maxX
	minY = Global.minY
	maxY = Global.maxY
	
	Col2D.disabled = 0
	
	player = Global.player
	
	
	type = randi() % 4
	
	if type == 0: # Default, regular speed, deals if 50 close
		Sprite.texture = alt1
	
	elif type == 1: # Havan, fast, always deals if NPCs in screen
		Sprite.texture = alt2
	
	elif type == 2: # Gman, goes for closest traget
		Sprite.texture = alt3
	
	elif type == 3: # Badd, always goes for attack if player on screen
		Sprite.texture = alt4
	
	update_speed()
	
	deal_lock = 0



func _physics_process(_delta):
	$Debug.text = str(npcb_target," ",npcb_target_position)
	
	motion = move_and_slide(motion, Vector2(0,-1))
	
	if state == 2 && playeranger != 0: #Aka ENGAGE
		if faketimer > 0:
			faketimer -= 1
		elif faketimer == 0:
			change_state(STATES.SHOOTING)


func _process(_delta):
	match state:
		STATES.IDLE: # 0
			idle()
		STATES.DOORSPAWN: # 1
			queue_free()
		STATES.ENGAGE: # 2
			engage()
		STATES.SHOOTING: # 3
			shooting()
		STATES.OUCH: # 4
			var damage
			take_damage(damage)
		STATES.GIVEUP: # 5
			surrender()
		STATES.NPCB_ENGAGE: # 6
			npcb_engage()
	
	Shadow.frame = Sprite.frame
	
	if face_dir == 1:
		set_flipped(false)
	elif face_dir == -1:
		set_flipped(true)
	
	
	system_msecs = OS.get_system_time_msecs()
	
	if state != 1:
		if position.y > minY: #460
			position.y += minY-position.y
		elif position.y < maxY: ##246
			position.y += maxY-position.y
		
		if position.x > maxX: ##2900
			position.x += maxX-position.x
		elif position.x < minX: #0
			position.x += minX-position.x
		
		self.z_index = round(position.y/10)-1

	if state == 0: #If in idle, delay notice
		
		if ((howmany*2)*1000) % 10000 == 0:
			howmany = (howmany/10) + 1
		
		if (system_msecs % ((howmany*2)*1000)) == 0:# every 'howmany'*2 seconds 
			playerX = position.x - player.position.x
			playerY = position.y - player.position.y #This works half-well, number may be to high and make way too long to notice
			
	elif state == 6:
		pass
		
	else: #Else, don't, or they'll be unpredicable to surrender
		if (system_msecs % 100) == 0:# every half seconds #WAS 500
			playerX = position.x - player.position.x
			playerY = position.y - player.position.y
			
	
	
	if state != 4: #If not in damage, surrendering code
		if abs(playerX) < 45 && abs(playerY) < 15 && giveup != 4 && player.holster == -1: ## beginning ##
			giveup = 2
			AniPlay.play("giveup")
			change_state(STATES.GIVEUP)





func idle():
	sight = abs(get_viewport().size.x)/2
	
	motion.x = 0
	motion.y = 0
	
	if abs(playerX) < sight:
		timerstep = (randi() % 7) #between 0 and 6
		faketimer = timervalues[timerstep]
		wasfaketimer = faketimer
		change_state(STATES.ENGAGE)
	else:
		if (timerstep % 2 == 0): #Else, idle
			AniPlay.play("idle2")
		else:
			AniPlay.play("taunt")


func engage():
	if target == 1:
		npcb_lookfor()
		DealCol.disabled = 0
		change_state(STATES.NPCB_ENGAGE)
	
	elif target == 0:
		#target = 1
		
		if abs(playerX) > sight-howmany:
			change_state(STATES.IDLE)
		
		face_dir = -sign(playerX)
		
		if playeranger != 0:
			if abs(motion.x) > 1 or abs(motion.y) > 1: # Walking animation #
				AniPlay.play("walkback")
			else:
				AniPlay.play("gonnashoot")
			
			
			
			if faketimer < (wasfaketimer/1.5):
				if blockX != face_dir:
					motion.x = speed*-face_dir
				else:
					motion.x = 0
				
				
				if blockY != -(sign(playerY)):
					motion.y = speed*sign(playerY)
				else:
					motion.y = 0
			
		else:
			motion.x = 0
			motion.y = 0
			
			AniPlay.stop()
			
			if playerY > 55: #up
				Sprite.frame = 25
				
			elif playerY < -55: #down
				Sprite.frame = 35
				
			else: #side
				Sprite.frame = 20#/30
			
			
			var wr = weakref(npcb_target)
			
			if (wr.get_ref()): #god-sent command
				if npcb_target.fear == 1:
					playeranger = 1
				elif abs(npcb_target.fear) != 1:
					target = 1
			else:
				playeranger = 1



export var target = 0


var npcbs_in_scene = [] #only for checking, try not to use elsewhere

var npcb_target = null

var npcb_target_position = Vector2(INF,INF)

var npcb_targetX = INF
var npcb_targetY = INF


func npcb_lookfor():
	npcbs_in_scene = get_tree().get_nodes_in_group("npcb")
	
	if npcbs_in_scene.size() != 0:
		for item in npcbs_in_scene:
			var wr = weakref(item)
			
			if (wr.get_ref()):
				if abs(item.position.x - position.x) < abs(npcb_target_position.x):
					if item != was_npcb_target:
						npcb_target = item
						npcb_target_position = Vector2(item.position)
						
						was_npcb_target = null
	else:
		no_target_wander()
		pass

func no_target_wander():
#	target = 0
#	playeranger = 1

#func no_target_wanderrrrrrr():
	if (timerstep % 2 == 0):
		npcb_target_position.x = minX
	else:
		npcb_target_position.x = maxX
	
	
	if abs(minY - position.y) < abs(maxY - position.y):
		npcb_target_position.y = minY
		
	else:
		npcb_target_position.y = maxY



export var deal_lock = 0

var playeranger = 0

func npcb_engage():
	if target == 0:
		change_state(STATES.ENGAGE)
	
	
	elif target == 1:
		
		#Used outside if null, to wander around, if there are no more targets left
		npcb_targetX = npcb_target_position.x - position.x 
		npcb_targetY = npcb_target_position.y - position.y
		
		if npcb_target != null:
			update_current_npcb_target_position() #This was supposed to go much later, as to not have the doctor roam into the NPC, but it won't fucking work
			
			
			if deal_lock == 0:
				AniPlay.play("walk")
			
				face_dir = sign(npcb_targetX) 
			
			#print(npcb_target_position)
			
			
			
			var wr = weakref(npcb_target)
			
			if (wr.get_ref()):
				if npcb_target.fear != 0:
					target = 0
					if npcb_target.fear == 1:
						playeranger = 1
			#else:
			#	clear_npcb_targets()
			
			
			
			if abs(npcb_targetX) < 45:
				motion.x = 0#(speed/2)*sign(npcb_targetX)
				motion.y = speed*sign(npcb_targetY)
				
				#update_current_npcb_target_position()
				
				if abs(npcb_targetY) < 5: #IN REACH!!
					if npcb_target != was_npcb_target:
						if deal_lock == 0:
							deal_lock = 1
						
						elif deal_lock == 1:
							if (wr.get_ref()):
								AniPlay.play("deal")
							else:
								deal_lock = 2
						
						elif deal_lock == 2:
							clear_npcb_targets() #for whatever mysterious reson deal_lock won't become 0
						
						

					
			else:
				if deal_lock != 1:
					motion.x = speed*sign(npcb_targetX)
					motion.y = (speed/2)*sign(npcb_targetY)
				else:
					clear_npcb_targets()
			
			
		else:
			face_dir = sign(npcb_targetX) 
			#Type exception time! When no more targets, what do? Wait, walk away, or attack the player?
			
			npcb_lookfor()
			
			AniPlay.play("walk")
			motion.x = speed*sign(npcb_targetX)
			motion.y = (speed/2)*sign(npcb_targetY)
			
			#if (timerstep % 2 == 0): #Else, idle
			#	AniPlay.play("idle2")
			#else:
			#	AniPlay.play("taunt")
			
			
		###################
		
		
		
		
		
		
		for body in npcb_deal:
			if body.npcb == 1:
				if body.fear == 0 && body.dortor_dad == null:
					if npcb_give == 1:
						var dortor_dad = self
						npcb_deal[0].cloroquina(dortor_dad)
						
						body.face_dir = -sign(npcb_targetX)
						
						
					if deal_lock == 2:
						if npcb_deal.has(body):
							npcb_deal.erase(body)
						
						clear_npcb_targets()
						
						
				else:
					target = 0
					
					#if npcb_deal.has(body):
					#	npcb_deal.erase(body)
			else:
				if npcb_deal.has(body):
					npcb_deal.erase(body)
				
				clear_npcb_targets()

var npcbs_0 = []


func update_current_npcb_target_position():
#	npcbs_in_scene = get_tree().get_nodes_in_group("npcb")
	
#	if npcbs_in_scene.size() != 0:
	for item in npcbs_in_scene:
		var wr = weakref(item)
		
		if (wr.get_ref()):
			if item == npcb_target:
				npcb_target_position = Vector2(item.position)



func clear_npcb_targets(): #onready values
	was_npcb_target = npcb_target
	
	npcbs_in_scene = [] #only for checking, try not to use elsewhere
	npcb_target = null
	npcb_target_position = Vector2(INF,INF)
	npcb_targetX = INF
	npcb_targetY = INF
	
	deal_lock = 0

var was_npcb_target


export var npcb_give = 0















func surrender():
	motion.x = 0
	motion.y = 0
	if giveup == 2: ## surrending ##
		if abs(playerX) < 45 && abs(playerY) < 15:
			AniPlay.playback_speed = 1.5
		else: # if player is too far, goto de-surrending
			giveup = -2
	
	elif giveup == -2: ## de-surrending / resistence ##
		AniPlay.playback_speed = -1
		if abs(playerX) < 45 && abs(playerY) < 15:
			giveup = 2 #if the player is again in range, goto surrending

	elif giveup == 3: ## 'state' reverser ##
		if abs(playerX) < 45 && abs(playerY) < 15:
			giveup = 2 #if the player is again in range, goto surrending
		else: 
			AniPlay.playback_speed = 1
			giveup = 0 #de-surrending complete, begin normal behavior
			change_state(STATES.ENGAGE)

	elif giveup == 4: ## surrender complete ##
		#Col2D.disabled = 1
		dead = -1
		AniPlay.play("giveupover")
	
	else:
		AniPlay.playback_speed = 1
		giveup = 0
		change_state(STATES.ENGAGE)



func doorspawn():
	AniPlay.play("walkdown")
	motion.y = speed
	if position.y > maxY:
		motion.y = 0
		sight = abs(get_viewport().size.x)/2
		change_state(STATES.IDLE)

func shooting():
	motion.y = 0
	motion.x = 0
	wasfaketimer = faketimer
	
	if playerY > 65:
		AniPlay.play("throwUp")
		bulletY = -1
	elif playerY < -65:
		AniPlay.play("throwDown")
		bulletY = 1
	else:
		bulletY = 0
		if (timerstep % 2 == 0):
			AniPlay.play("throwSide")
		else:
			AniPlay.play("throwSideII")



func shoot():
	$Audio.JUMPa()
	var bul_instance = BUL_ENTITY.instance()
	
	bul_instance.dirY = bulletY
	
	if abs(playerX) > 45:
		bul_instance.dirX = face_dir
	else:
		if bulletY != 0:
			bul_instance.dirX = 0
		else:
			bul_instance.dirX = face_dir
	
	bul_instance.position = position+Vector2((30*face_dir),(48))
	bul_instance.posZ = 48
	
	#Randomize next timer#
	timerstep = (randi() % 7) #between 0 and 6
	faketimer = timervalues[timerstep]
	
	get_parent().add_child(bul_instance)


func take_cloroquina():
	pass



export var dead = 0

func take_damage(_damage):
	dead = 1
	
	motion.x = 0
	motion.y = 0
	
	change_state(STATES.OUCH)
	if (timerstep % 2 == 0):
		AniPlay.play("die1")
	else:
		AniPlay.play("die2")
	
	if AniPlay.playback_speed < 1:
		AniPlay.playback_speed = 1

func SAFEDIE():
	Global.foes -= 1
	queue_free()

func giveupScore():
	Global.player.score += 2000



func set_flipped(flipstate):
	if flipstate: ### LEFT ### -1
		Sprite.flip_h = true
		Shadow.flip_h = true
		DealCol.position.x = -20
	else: ########### RIGHT ### 1
		Sprite.flip_h = false
		Shadow.flip_h = false
		DealCol.position.x = 20



func update_speed():
		if type == 0:
			if target == 1:
				speed = 75
			else:
				speed = 100
		
		elif type == 1:
			if target == 1:
				speed = 90
			else:
				speed = 90
		
		elif type == 2:
			if target == 1:
				speed = 110
			else:
				speed = 80
		
		elif type == 3:
			if target == 1:
				speed = 70
			else:
				speed = 125



var npcb_deal = []

func _on_Lazy2D_body_entered(body):
	if body.is_in_group("npcb"):
		if body.fear != 1:
			body.wait = 1
			
			if !npcb_deal.has(body):
				npcb_deal.push_back(body)


func _on_Lazy2D_body_exited(body):
	if body.is_in_group("npcb"):
		body.wait = 0
		
		if npcb_deal.has(body):
			npcb_deal.erase(body)

func remove_radar():
	self.remove_from_group('radar_me')
