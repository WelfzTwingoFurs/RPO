extends AudioStreamPlayer

var which

const STEP1 = preload("res://media/sons2/step0.wav")
const STEP2 = preload("res://media/sons2/step1.wav")
const STEP3 = preload("res://media/sons2/step2.wav")
const STEP4 = preload("res://media/sons2/step3.wav")

func STEPs():
	which = (randi() % 4)
	if which == 0:
		set_stream(STEP1)
	if which == 1:
		set_stream(STEP2)
	if which == 2:
		set_stream(STEP3)
	if which == 3:
		set_stream(STEP4)
	play()

const PAIN1 = preload("res://media/sons/ply_pain.wav")
const PAIN2 = preload("res://media/sons/ply_pain2.wav")
func PAINs():
	which = (randi() % 2)
	if which == 0:
		set_stream(PAIN1)
	if which == 1:
		set_stream(PAIN2)
	play()

const SHOOT1 = preload("res://media/sons2/little-gun1.wav")
const SHOOT2 = preload("res://media/sons2/little-gun2.wav")
func SHOOTs():
	which = (randi() % 2)
	if which == 0:
		set_stream(SHOOT1)
	if which == 1:
		set_stream(SHOOT2)
	play()

const ENSHOOT = preload("res://media/sons2/recruta-gun.wav")
func ENSHOOTa():
	set_stream(ENSHOOT)
	play()

const JUMP = preload("res://media/sons2/jump.wav")
func JUMPa():
	set_stream(JUMP)
	play()

const LAND = preload("res://media/sons2/land.wav")
func LANDa():
	set_stream(LAND)
	play()

const DIE = preload("res://media/sons/ply_die.wav")
func DIEa():
	set_stream(DIE)
	play()

const ENDIE1 = preload("res://media/sons/sci_die1.wav")
const ENDIE2 = preload("res://media/sons/sci_die2.wav")
const ENDIE3 = preload("res://media/sons/sci_die3.wav")
func ENDIEs():
	which = (randi() % 3)
	if which == 0:
		set_stream(ENDIE1)
	if which == 1:
		set_stream(ENDIE2)
	if which == 2:
		set_stream(ENDIE3)
	play()

const TING = preload("res://media/sons/ting2.wav")
func TINGa():
	set_stream(TING)
	play()

const FRIENDIE1 = preload("res://media/sons2/friendie1.wav")
const FRIENDIE2 = preload("res://media/sons2/friendie2.wav")
func FRIENDIEs():
	which = (randi() % 2)
	if which == 0:
		set_stream(FRIENDIE1)
	if which == 1:
		set_stream(FRIENDIE2)
	play()

const CARENGINE1 = preload("res://media/carros/SedanEngine.wav")
func car_engine():
	set_stream(CARENGINE1)
	if !is_playing():
		play()

const TIRESQUEAK = preload("res://media/carros/Tire.wav")
func car_tire():
	set_stream(TIRESQUEAK)
	if !is_playing():
		play()

const CARHIT = preload("res://media/sons2/big-gun.wav")#Damage3.wav")
func car_ouch():
	set_stream(CARHIT)
	play()

const ITEM_AMMO1 = preload("res://media/sons2/item2-ammo.wav")
func ammo1get():
	set_stream(ITEM_AMMO1)
	play()

const ITEM_MONEY = preload("res://media/sons2/item2-money.wav")
func moneyget():
	set_stream(ITEM_MONEY)
	play()

const ITEM_CLORO = preload("res://media/sons2/tingtingting.wav")
func cloroget():
	set_stream(ITEM_CLORO)
	play()

const ITEM_CAN = preload("res://media/sons2/booboop.wav")
func canget():
	set_stream(ITEM_CAN)
	play()
