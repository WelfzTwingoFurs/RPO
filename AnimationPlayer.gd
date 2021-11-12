extends AnimationPlayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	play("New Anim")

func _process(delta):
	$Sprite2.frame = $Sprite.frame
	$Sprite3.frame = $Sprite.frame + 10
	$Sprite4.frame = $Sprite.frame + 10
	$Sprite5.frame = $Sprite.frame + 9
	$Sprite6.frame = $Sprite.frame + 39
	$Sprite8.frame = $Sprite.frame + 9
	$Sprite9.frame = $Sprite.frame + 19
	$Sprite10.frame = $Sprite.frame + 29

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
