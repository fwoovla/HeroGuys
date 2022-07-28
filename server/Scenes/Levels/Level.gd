extends Spatial

onready var spawn1 = get_node("Spawns/1")
onready var spawn2 = get_node("Spawns/2")
onready var nav = get_node("Navigation")

var troop_scene = preload("res://Scenes/Troops/Troop.tscn")

var troops : = {} 		#contains troop nodes
var spectators : = {}	#contains nodes


var started = false
var num_in_game = 0

func _ready():
	var troop_num = 1
	for troop in Network.team_1:
		print("adding troop: ,", troop)
		var t = troop_scene.instance()
		$Team_1.add_child(t)
		t.name = Network.team_1[troop_num]["name"]
		troops[Network.team_1[troop_num]["name"]] = t
		t.set_network_master(Network.ready_players[0])
		t.init_troop(Network.team_1[troop_num], 1)
		t.nav = nav
		t.global_transform.origin = spawn1.get_node("Pos" + str(troop_num)).global_transform.origin
		troop_num +=1
		
	troop_num = 1
	for troop in Network.team_2:
		print("adding troop: ,", troop)
		var t = troop_scene.instance()
		$Team_2.add_child(t)
		t.name = Network.team_2[troop_num]["name"]
		troops[Network.team_2[troop_num]["name"]] = t
		t.set_network_master(Network.ready_players[1])
		t.init_troop(Network.team_2[troop_num], 2)
		t.data = Network.team_2[troop_num]
		t.global_transform.origin = spawn2.get_node("Pos" + str(troop_num)).global_transform.origin
		troop_num +=1
				
	print("troops in game", troops)
	#add teams
	pass

func _physics_process(delta):
	if get_tree().network_peer and started:
		Network.update_timer -= delta
		if Network.update_timer <= 0.0:
			if is_server():
				Network.update_timer = Network.HOST_RATE
				
				var player_states = [[]]
				for troop in troops:
					if is_instance_valid(troops[troop]):
						player_states[0].push_back([
						troops[troop].name,
						troops[troop].global_transform,
						troops[troop].translation, 
						troops[troop].rotation.x, 
						troops[troop].rotation.y, 
						troops[troop].rotation.z, 
						troops[troop].speed, 
						troops[troop].health
						])
						
				var npc_states = [[]]
				
				rpc_unreliable("update_world", player_states, npc_states)

func is_server():
	return get_tree().is_network_server()

remote func update_peer(troop_states : Array): #t:Vector3, rx:float, ry:float, rz:float, speed:float, health:int):
	for troop in troop_states:
		#print("\ntroopstates:", troop_states, "\ntroops:", troops, "\ntroop: ", troop, "\ntroop[0]: " ,troop[0])
		
		troops[troop[0]].global_transform = troop[1]
		troops[troop[0]].translation = troop[2]
		troops[troop[0]].rotation.x = troop[3]
		troops[troop[0]].rotation.y = troop[4]
		troops[troop[0]].rotation.z = troop[5]
		troops[troop[0]].speed = troop[6]
		troops[troop[0]].health = troop[7]
		#troops[troop[0]].update_puppet(player[1], player[2], player[3], player[4], player[5], player[6], player[7])


remote func in_game():
	var caller_id = get_tree().get_rpc_sender_id()
	num_in_game += 1
	if num_in_game == Network.ready_players.size():
		rpc("start_game")
		started = true
	
	
