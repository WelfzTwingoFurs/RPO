extends Sprite

onready var radar = self

onready var player1 = $Rplay1
onready var player2 = $Rplay2
onready var recruto = $Rrecruto
onready var dortor = $Rdortor
onready var car = $Rcar
onready var bullet = $Rbullet
onready var can = $Rcan
onready var cloro = $Rcloro
onready var money = $Rmoney
onready var meds = $Rmeds

#onready var icons = []
onready var icons = {"player1": player1,"player2": player2,"recruto": recruto,"dortor": dortor,"car": car,"bullet": bullet,"can": can,"cloro": cloro,"money": money,"meds": meds}


var display_icons = {}

var group_members = []

var minX = 0
var maxX = 973
var minY = 350
var maxY = 246

func _ready():
	minX = Global.minX
	maxX = Global.maxX
	
	minY = Global.minY
	maxY = Global.maxY

var system_msecs = 0

var laglock = 0

func _process(delta):
	
	system_msecs = OS.get_system_time_msecs()
	
#	if (system_msecs % 200) == 0:
#		print(system_msecs)
	
	#if (system_msecs % 9) == 0:
#	if laglock != system_msecs:
	if (system_msecs % 100) == 0:
		if laglock != system_msecs:
			group_members = get_tree().get_nodes_in_group("radar_me")

			for item in group_members:
				if !display_icons.has(item):
					var new_marker = icons[item.radar_icon].duplicate()
					radar.add_child(new_marker)
					new_marker.show()
					display_icons[item] = new_marker

			for item in display_icons:
				#if item != null:
				#if item.is_instance_valid():
				#if display_icons[item].is_instance_valid(item):
				#if item != $_NULL:
				#if item == null:
				var wr = weakref(item)
				if (wr.get_ref()):
					var item_position = (item.position/11)
					
					display_icons[item].position = Vector2(item_position.x -75,item_position.y/2)
					
					if item.radar_icon == "player1" or item.radar_icon == "player2" or item.radar_icon == "recruto" or item.radar_icon == "dortor":
						display_icons[item].scale.x = item.face_dir
					
					elif item.radar_icon == "car":
						if item.faceX != 0:
							display_icons[item].scale.x = item.faceX

				laglock = system_msecs
	else:
		for item in display_icons:
			var wr = weakref(item)
			if (!wr.get_ref()):
				display_icons[item].queue_free()
				display_icons.erase(item)
			
#			else:
#				if item.radar_icon == "player1":
#					if item.health == 0:
#						display_icons[item].queue_free()
#						display_icons.erase(item)
#
#				elif item.radar_icon == "recruto":
#					if item.ouch != 0:
#						display_icons[item].queue_free()
#						display_icons.erase(item)
#
#				elif item.radar_icon == "dortor":
#					if item.state == 4:
#						display_icons[item].queue_free()
#						display_icons.erase(item)
#
#				elif item.radar_icon == "player2":
#					if item.state == 2:
#						display_icons[item].queue_free()
#						display_icons.erase(item)
#
#				elif item.radar_icon == "bullet" or item.radar_icon == "can" or item.radar_icon == "cloro" or item.radar_icon =="money" or item.radar_icon =="meds":
#					if item.gotten == 1:
#						display_icons[item].queue_free()
#						display_icons.erase(item)
