extends Sprite
var label = self

export var shinetype = 0
var meganumbers = 0
var supernumbers = 0

var colR = 0
var colG = 0
var colB = 0

func _process(delta):
	meganumbers = abs(sin(OS.get_system_time_msecs() / 200))
	supernumbers = sin((OS.get_system_time_msecs() / 50 ))
	meganumbers = sin(OS.get_system_time_secs())
	
	colR = abs(supernumbers)
	colG = abs(supernumbers + meganumbers)
	colB = colR + meganumbers
	
	label.set_modulate(Color(colR,colG,colB,1))
