extends Label
var label = self

export var shinetype = 0
var meganumbers = 0
var supernumbers = 0

var colR = 0
var colG = 0
var colB = 0

func _ready():
	label.rect_scale.y = 25
func _process(delta):
	if shinetype == 1:
		meganumbers = abs(sin(OS.get_system_time_msecs() / 200))
		supernumbers = sin((OS.get_system_time_msecs() / 50 ))
		meganumbers = sin(OS.get_system_time_secs())
		
		colR = abs(supernumbers)
		colG = abs(supernumbers + meganumbers)
		colB = colR + meganumbers
		
		label.set("custom_colors/font_color", Color(colR,colG,colB))
	
	elif shinetype == 2:
		meganumbers = abs(sin(OS.get_system_time_msecs() / 200))
		
		label.set("custom_colors/font_color", Color(meganumbers,1,meganumbers/2))
		
		if label.rect_scale.y > 1:
			label.rect_scale.y -=0.1
