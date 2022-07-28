extends Node

const HOST_RATE : float = 1.0/20.0
const PEER_RATE : float = 1.0/60.0
var update_timer : float = 0.0

const DEFAULT_PORT = 44444
const MAX_PLAYERS = 100

const READY_MAX = 1


var players : = {}
var ready_players : = []

var team_1 : = {} #troop data  teams[ team1:{}, team2:{}. etc...  ]
var team_2 : = {}


var spawn_counter = 1000 #for naming
var in_game = false

signal start_game

func _ready():
	get_tree().connect("network_peer_connected", self, "player_connected")
	get_tree().connect("network_peer_disconnected", self, "player_disconnected")
	get_tree().connect("server_disconnected", self, "server_stopped")

func start_server():
	var host = NetworkedMultiplayerENet.new()
	var error = host.create_server(DEFAULT_PORT, MAX_PLAYERS)
	get_tree().network_peer = host
	print("Server created!  Port: " + str(DEFAULT_PORT), "  ", error)
	
func stop_server():
	get_tree().network_peer.close_connection()
	get_tree().quit()
	
func server_stopped():
	print("Network: Server stopped")
	
func player_connected(_id):
	print(_id, " connected ok")
	
func player_disconnected(_id):
	print("Network: ", _id, " disconnected ok")
	rpc("unregister_player", _id)

remote func register_player(info):
	print("Network: Registering new player", info)
	var caller_id = get_tree().get_rpc_sender_id()
	
	players[caller_id] = info
	#print(info["username"])
	for p in players:
		rpc_id(caller_id, "register_player", p, players[p], ready_players)
	rpc("register_player" , caller_id, players[caller_id], ready_players)
	print("current players: ")
	for player in players:
		print(players[player]["username"])
	print("------- ", players.size())
	
puppetsync func unregister_player(_id):
	print("Network: player ", _id, " unregistered")
	players.erase(_id)
	print("current players: ")
	for player in players:
		print(players[player]["username"])
	print("------- ", players.size())
	if in_game and _id in ready_players:
		ready_players.clear()
		team_1.clear()
		team_2.clear()
		in_game = false
		rpc("return_to_menu")
		get_tree().change_scene("res://Scenes/Main.tscn")


remote func ready_request(is_ready : bool, team_data : Dictionary):
	var caller_id = get_tree().get_rpc_sender_id()
	if is_ready:
		
		if ready_players.size() < READY_MAX:
			ready_players.append(caller_id)
			print(caller_id, " is ready!")
			
			if ready_players.size() == 1:
				team_1 = create_team(team_data)
				for troop in team_1:
					team_1[troop]["name"] = "t1_" + team_1[troop]["name"]
				rpc("player_ready", caller_id, true, 1, team_1, team_2)
				
			if ready_players.size() == 2:
				team_2 = create_team(team_data)
				for troop in team_2:
					team_2[troop]["name"] = "t2_" + team_2[troop]["name"]
				rpc("player_ready", caller_id, true, 2, team_1, team_2)
				
		else:
			rpc_id(caller_id, "ready_failed")
	else:
		print(caller_id, " is NOT ready!")
		if ready_players.has(caller_id):
			ready_players.erase(caller_id)
			rpc("player_ready", caller_id, false, 0, {}, {})
			
	if ready_players.size() == READY_MAX:
		emit_signal("start_game")
		rpc("start_game")
		in_game = true

func create_team(_data : Dictionary):  # WTF !?!
	var data = {}
	if ready_players.size() == 1:
		data = _data
	if ready_players.size() == 2:
		data = _data
		
	return data
