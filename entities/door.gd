extends Position2D

const RECRUTO = preload("res://entities/recruto.tscn")
const AMIGO = preload("res://entities/amigo.tscn")
const DORTOR = preload("res://entities/dortor.tscn")

export var timer = 0
export var rate = 0
export var ammo = 0

export var who = 0
var whotospawn

export var minX = 0
export var maxX = 0
# These will be set here, and exported to the spawning entities
export var minY = 0
export var maxY = 0

func _ready():
	if who == 0:
		whotospawn = RECRUTO
	elif who == 1:
		whotospawn = AMIGO
	elif who == 2:
		whotospawn = DORTOR

func _physics_process(delta):
	if rate != 0 && ammo != 0:
		$Label.text = str(rate,"-",timer,", ",ammo)
		
		if timer > 0:
			timer -= 1 * Engine.time_scale 
		elif timer < 1:
			$AnimationPlayer.play("do")
			timer = rate
	else:
#		if who == "":
#			$Label.text = str("DEFINE AN ENEMY!")
		if rate == 0:
			$Label.text = str("RATE IS 0!")
		if ammo == 0:
			$Label.text = str("NO AMMO")

func shoot():
	ammo -= 1
	var bul_instance = whotospawn.instance()
	bul_instance.scale = self.scale
	bul_instance.position = Vector2(position.x,position.y-60)
	
	bul_instance.minX = minX
	bul_instance.maxX = maxX
	bul_instance.minY = minY
	bul_instance.maxY = maxY
	
	get_parent().add_child(bul_instance)
