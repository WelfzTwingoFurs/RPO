extends AudioStreamPlayer

const music1 = preload("res://media/musica/nuff.mp3")
const music2 = preload("res://media/musica/rpo.mp3")
const music3 = preload("res://media/musica/rpo2.mp3")
const music4 = preload("res://media/musica/dork.wav")
const music5 = preload("res://media/musica/drok.wav")
const music6 = preload("res://media/musica/whollo.wav")
const music7 = preload("res://media/musica/arcade.wav")
const music8 = preload("res://media/musica/slyTwo.wav")
const music9 = preload("res://media/musica/annoia.wav")
const music10 = preload("res://media/musica/peaceful.wav")
const music11 = preload("res://media/musica/rush-desertwalk.wav")

var which = 11

var label

func _ready():
	label = $song
	playit()

func _process(delta):
	if Input.is_action_just_pressed("M"):
		if which < 11:
			which += 1
			playit()
		else:
			which = 0
			playit()

func playit():
	if which == 11:
		stop()
		if label != null:
			label.text = str("[M] for song-test!")
	else:
		if which == 0:
			set_stream(music1)
		if which == 1:
			set_stream(music2)
		if which == 2:
			set_stream(music3)
		if which == 3:
			set_stream(music4)
		if which == 4:
			set_stream(music5)
		if which == 5:
			set_stream(music6)
		if which == 6:
			set_stream(music7)
		if which == 7:
			set_stream(music8)
		if which == 8:
			set_stream(music9)
		if which == 9:
			set_stream(music10)
		if which == 10:
			set_stream(music11)
		play()
		
		if label != null:
			label.text = str(stream.resource_path.get_file().get_basename())
