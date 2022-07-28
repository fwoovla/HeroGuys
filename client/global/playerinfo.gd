extends Node


var troops : = {}
var team = 0 #for spawn

var troop_1 := {}
var troop_2 := {}
var troop_3 := {}
var troop_4 := {}


func _ready():
	randomize()
	troop_1 = Gamesettings.soldier_data
	troop_2 = Gamesettings.soldier_data
	troop_3 = Gamesettings.soldier_data
	troop_4 = Gamesettings.soldier_data
	#troops = {"commander" + str(randi() % 100):{}, "grunt" + str(randi() % 100):{}, "grunt" + str(randi() % 100):{}, "grunt" + str(randi() % 100):{}}
	print(troops)

func update_troop(troop_num, data):
	if troop_num == 1:
		troop_1 = data
	if troop_num == 2:
		troop_2 = data
	if troop_num == 3:
		troop_3 = data
	if troop_num == 4:
		troop_4 = data
		

func assemble_trooops():
	troops[1] = troop_1
	troops[2] = troop_2
	troops[3] = troop_3
	troops[4] = troop_4
	print(troops)
	return troops
