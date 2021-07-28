extends AudioStreamPlayer

const music1 = preload("res://media/musica/rposong.mp3")
const music2 = preload("res://media/musica/rposong2.mp3")
const music3 = preload("res://media/musica/rposong4.mp3")

var which = 3

func _ready():
	playit()

func _process(delta):
	if Input.is_action_just_pressed("M"):
		if which < 3:
			which += 1
			playit()
		else:
			which = 0
			playit()

func playit():
	if which == 3:
		stop()
	else:
		if which == 0:
			set_stream(music1)
		if which == 1:
			set_stream(music2)
		if which == 2:
			set_stream(music3)
		play()
