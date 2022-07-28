extends TextureRect

var troop1pic = 1
var troop2pic = 1
var troop3pic = 1
var troop4pic = 1


func _ready():
	update_team()

func _on_left_pressed_1():
	troop1pic -=1
	if troop1pic < 1:
		troop1pic = 4
	update_team()

func _on_right_pressed_1():
	troop1pic +=1
	if troop1pic > 4:
		troop1pic = 1
	update_team()
	
	

func _on_left_pressed_2():
	troop2pic -=1
	if troop2pic < 1:
		troop2pic = 4
	update_team()
	
func _on_right_pressed_2():
	troop2pic +=1
	if troop2pic > 4:
		troop2pic = 1
	update_team()



func _on_left_pressed_3():
	troop3pic -=1
	if troop3pic < 1:
		troop3pic = 4
	update_team()

func _on_right_pressed_3():
	troop3pic +=1
	if troop3pic > 4:
		troop3pic = 1
	update_team()



func _on_left_pressed_4():
	troop4pic -=1
	if troop4pic < 1:
		troop4pic = 4
	update_team()

func _on_right_pressed_4():
	troop4pic +=1
	if troop4pic > 4:
		troop4pic = 1
	update_team()


func update_team():
	var multi_count = 2 
	
	Playerinfo.troop_1 = Gamesettings.troop_data[troop1pic].duplicate(true)
	
	Playerinfo.troop_2 = Gamesettings.troop_data[troop2pic].duplicate(true)
	if Playerinfo.troop_1["name"] == Playerinfo.troop_2["name"]:
		Playerinfo.troop_2["name"] = Playerinfo.troop_2["name"] + str(multi_count)
		multi_count +=1
		
	Playerinfo.troop_3 = Gamesettings.troop_data[troop3pic].duplicate(true)
	if Playerinfo.troop_1["name"] == Playerinfo.troop_3["name"] or Playerinfo.troop_2["name"] == Playerinfo.troop_3["name"]:
		Playerinfo.troop_3["name"] = Playerinfo.troop_3["name"] + str(multi_count)
		multi_count +=1
		
		
	Playerinfo.troop_4 = Gamesettings.troop_data[troop4pic].duplicate(true)
	if Playerinfo.troop_1["name"] == Playerinfo.troop_4["name"] or Playerinfo.troop_2["name"] == Playerinfo.troop_4["name"] or Playerinfo.troop_3["name"] == Playerinfo.troop_4["name"]:
		Playerinfo.troop_4["name"] = Playerinfo.troop_4["name"] + str(multi_count)
		multi_count +=1
		
		
	$Troop1.texture_normal = Gamesettings.portraits[troop1pic]
	$Troop2.texture_normal = Gamesettings.portraits[troop2pic]
	$Troop3.texture_normal = Gamesettings.portraits[troop3pic]
	$Troop4.texture_normal = Gamesettings.portraits[troop4pic]
	
	$Troop1/Label.text = Playerinfo.troop_1["name"]
	$Troop2/Label.text = Playerinfo.troop_2["name"]
	$Troop3/Label.text = Playerinfo.troop_3["name"]
	$Troop4/Label.text = Playerinfo.troop_4["name"]
	pass
