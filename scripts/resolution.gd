extends Node

var debugging = 1

var player

var minX = 0
var maxX = 2900
# These will be set in-level, exported to global, then imported to entities.
var minY = 460
var maxY = 246

var foes = 0
var friends = 0
var npcs = 0

var lane1
var lane2

var point_of_interest = Vector2(INF,INF)

# 0 = forget it, 1 = attack, 2 = death, 3 = scream/grunt, 4 = item
var interest_type = 0

## Resolution stuff below, debugging keys lower ##
var WindowX
var WindowY

var step = 0
onready var resolution = 2

var smelly



func _ready():
	smelly = OS.get_screen_size()


func _process(_delta):
	WindowX = OS.window_size.x
	WindowY = OS.window_size.y
	
	### Resolution process ###
	if step == 0:
		
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP_HEIGHT, Vector2(WindowX, WindowY))
		OS.center_window() # Viewport, Keep_Height
		OS.window_size.x = smelly.x # Window as <wide> as monitor
	
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP_WIDTH, Vector2(WindowX, WindowY))
		OS.center_window() # Viewport, Keep_Widht
		OS.window_size.y = smelly.y # Window as ^tall^ as monitor

		step = 1
	
	
	elif step == 1:
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED, SceneTree.STRETCH_ASPECT_IGNORE, Vector2(WindowX, WindowY))
		OS.window_size /= resolution # Disabled, Ignore
		OS.center_window() # Window res/2
		
		step = 2
	
	
	elif step == 2:
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP, Vector2(WindowX, WindowY))
		OS.window_size *= resolution # Viewport, Keep
		OS.center_window() # Window res*2
		
		step = 3
		if player != null:
			player.hudconfig()
		

	
	# Debugging commands below #
	
	else:
		if Input.is_action_just_pressed("bug_resdivide"): # 1
			OS.window_size /= 2
			OS.center_window()
			player.hudconfig()
		
		if Input.is_action_just_pressed("bug_resmultiply"): # 2
			OS.window_size *= 2
			OS.center_window()
			player.hudconfig()
		
		if Input.is_action_just_pressed("bug_resagain"): # 3
			step = 0
		
		if Input.is_action_just_pressed("bug_cheat"):
			player.health = (player.health+1) *9
			player.ammo1 = 999
			player.state = 0
			if player.ouch == 1:
				player.ouch = 0
				player.last_dir = 0
				player.Col2D.disabled = 0
		
		if Input.is_action_just_pressed("bug_reset"): #5
			foes = 0
			friends = 0
			npcs = 0
			point_of_interest = Vector2(INF,INF)
			interest_type = 0
			Engine.time_scale = 1
			get_tree().reload_current_scene()
		
		elif Input.is_action_just_released("bug_reset"):
			player.hudconfig()
		
		if Input.is_action_just_pressed("bug_resplus"):
				resolution += 1
				step = 0
		
		elif Input.is_action_just_pressed("bug_resminus"):
			if resolution > 1:
				resolution -= 1
				step = 0
			else:
				print("Nope!")
		
		if Input.is_action_just_pressed("bug_speeddown"):
			Engine.time_scale -= 0.2
		
		elif Input.is_action_just_pressed("bug_speedup"):
			Engine.time_scale += 0.2
		
		elif Input.is_action_just_pressed("bug_speedres"):
			Engine.time_scale = 1
		
		elif Input.is_action_just_pressed("bug_speedstop"):
			Engine.time_scale = 0
		
		if Input.is_action_just_pressed("bug_level_select"):
			get_tree().change_scene("res://scenes/level-select.tscn")
	
