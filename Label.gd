extends Label
var meganumbers
var label = self
func _ready():
	label.rect_scale.y = 25
func _process(delta):
	meganumbers = abs(sin(OS.get_system_time_msecs() / 200))
	label.set("custom_colors/font_color", Color(meganumbers,1,meganumbers/2))
	
	if label.rect_scale.y > 1:
		label.rect_scale.y -=0.1
