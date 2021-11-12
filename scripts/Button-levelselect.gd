extends Button

export var scene = ""

#res://scenes/*.tscn

func _on_Button_pressed():
	if scene != null:
		get_tree().change_scene(scene)
