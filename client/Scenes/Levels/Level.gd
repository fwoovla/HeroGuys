extends Spatial

var troop_scene = preload("res://Scenes/Troops/Troop.tscn")

var team_colors = [Color.cyan, Color.magenta]

onready var spawn1 = get_node("Spawns/1")
onready var spawn2 = get_node("Spawns/2")
onready var nav = get_node("Navigation")
onready var fps_label = get_node("HudOverlay/FPS")

var hometeam : = {} 		#contains nodes
var awayteam : = {}
var spectators : = {}	#contains nodes

var started = false

func _ready():
	if Gamesettings.lighting == false:
		for light in $Lighting.get_children():
			light.hide()
			
	$HudOverlay/Label.text = "Team " + str(Playerinfo.team)
	print("team 1: ", Network.team_1)
	print("team 2: ", Network.team_2)
	
	var troop_num = 1
	
	for troop in Network.team_1:
		var t = troop_scene.instance()
		if Playerinfo.team == 1:
			$Team_1.add_child(t)
			hometeam[Network.team_1[troop_num]["name"]] = t
			t.init_troop(Network.team_1[troop_num], 1, true, nav)
			t.global_transform.origin = spawn1.get_node("Pos" + str(troop_num)).global_transform.origin
		if Playerinfo.team == 2:
			$Team_1.add_child(t)
			awayteam[Network.team_1[troop_num]["name"]] = t
			t.init_troop(Network.team_1[troop_num], 1, false, nav)
			t.global_transform.origin = spawn1.get_node("Pos" + str(troop_num)).global_transform.origin
		t.name = Network.team_1[troop_num]["name"]
		troop_num +=1


	troop_num = 1
	for troop in Network.team_2:
		var t = troop_scene.instance()
		if Playerinfo.team == 2:
			$Team_2.add_child(t)
			hometeam[Network.team_2[troop_num]["name"]] = t
			t.init_troop(Network.team_2[troop], 2, true, nav)
			t.global_transform.origin = spawn2.get_node("Pos" + str(troop_num)).global_transform.origin
		if Playerinfo.team == 1:
			$Team_2.add_child(t)
			awayteam[Network.team_2[troop_num]["name"]] = t
			t.init_troop(Network.team_2[troop], 2, false, nav)
			t.global_transform.origin = spawn2.get_node("Pos" + str(troop_num)).global_transform.origin
		t.name = Network.team_2[troop_num]["name"]
		troop_num +=1

	
	if Playerinfo.team == 1:
		$CameraBase.camera_pos = spawn1.global_transform.origin
		
	if Playerinfo.team == 2:
		$CameraBase.rotation_degrees.y = 180
		$CameraBase.camera_pos = spawn2.global_transform.origin
		
	rpc_id(1, "in_game")

func _physics_process(delta):
	fps_label.text = str(Engine.get_frames_per_second())
	if get_tree().network_peer and started:
		Network.update_timer -= delta
		if Network.update_timer <= 0.0:
			Network.update_timer = Network.PEER_RATE
			var player_states = []
			for player in hometeam:
				if is_instance_valid(hometeam[player]):
					player_states.push_back([
					hometeam[player].name,
					hometeam[player].global_transform,
					hometeam[player].translation, 
					hometeam[player].rotation.x, 
					hometeam[player].rotation.y, 
					hometeam[player].rotation.z, 
					hometeam[player].speed, 
					hometeam[player].health
					])
					
			rpc_unreliable_id(1, "update_peer", player_states)

puppet func update_world(troop_states : Array, npc_states : Array):
	#print("states :", player_states)
	for troop in troop_states[0]:
		#print("player: ", player)
		#print("player state player: ", player[0])
		if awayteam.has(troop[0]): # and player_states.size() > 0:
			#print("away team: ", troop[0])
			awayteam[troop[0]].update_puppet(
					troop[1], 
					troop[2], 
					troop[3], 
					troop[4], 
					troop[5], 
					troop[6], 
					troop[7])

remote func start_game():
	started = true

func _on_Quit_pressed():
	get_tree().quit()


func draw_path(path_array):
	if path_array.size()  == 0:
		return
	var m = SpatialMaterial.new()
	var im = get_node("Draw")
	im.set_material_override(m)
	im.clear()
	im.begin(Mesh.PRIMITIVE_POINTS, null)
	im.add_vertex(path_array[0])
	im.add_vertex(path_array[path_array.size() - 1])
	im.end()
	im.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	for x in path_array:
		im.add_vertex(x)
	im.end()


func _on_Settings_Back_pressed():
	update_settings()
	$HudOverlay/SettingsPanel.hide()


func update_settings():
	for light in $Lighting.get_children():
		light.visible = Gamesettings.lighting
		
	for light in get_node("Lighting").get_children():
		light.shadow_enabled = Gamesettings.shadows

