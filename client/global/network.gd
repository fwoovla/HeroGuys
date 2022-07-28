extends Node

const HOST_RATE : float = 1.0/20.0
const PEER_RATE : float = 1.0/60.0
var update_timer : float = 0.0


const server_ip = "31.220.49.156"

const external_ip = "31.220.49.156"
const DEFAULT_PORT = 44444
const local_ip = "192.168.01.7"
var ip_address

var username = ""

var players : = {}
var ready_players : = []

var team_1 = {}
var team_2 = {}

signal connected_ok
signal connected_fail
signal update_players
signal is_ready
signal start_game

func _ready():
	#ip_address = local_ip
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")


func connect_to_server():
	var client = NetworkedMultiplayerENet.new()
	client.create_client(ip_address, DEFAULT_PORT)
	get_tree().network_peer = client
	#print("Network: Attempting connection with server at " + str(local_ip))

func _connected_ok():
	emit_signal("connected_ok")
	print("Network: Sucsess!")
	var new_info = {"username":username} #Playerinfo.bundle_info()
	rpc_id(1, "register_player", new_info)
	
	get_tree().change_scene("res://Scenes/GameMenu.tscn")

func _connected_fail():
	emit_signal("connected_fail")
	print("Network: Failed!")
	get_tree().network_peer = null  #reset and try again
	connect_to_server()

func _server_disconnected():
	print("Network: Server Closed!")
	get_tree().network_peer = null  #reset and try again
	connect_to_server()

remote func register_player(_id, info, _ready_players):
	print("registered plaeyer, ", _id, info)
	players[_id] = info
	ready_players = _ready_players
	emit_signal("update_players")
	
remote func unregister_player(_id):
	print("Network: unregistering player " + str(_id))
	players.erase(_id)
	if ready_players.has(_id):
		if ready_players[0] == _id:
			team_1.clear()
		if ready_players[1] == _id:
			team_2.clear()
		ready_players.erase(_id)
		
	emit_signal("update_players")

remote func player_ready(_id : int, is_ready : bool, team : int, _team_1_data: Dictionary, _team_2_data: Dictionary):
	if is_ready:
		print(players[_id]["username"], " is ready")
		ready_players.append(_id)
		
		if _id == get_tree().get_network_unique_id():
			emit_signal("is_ready", true)
			Playerinfo.team = team
			
		team_1 = _team_1_data
		print("team 1 ready: ", ready_players[0], team_1)
		team_2 = _team_2_data
		if ready_players.size() > 1:
			print("team 2 ready: ", ready_players[1])

	else:
		print(players[_id]["username"], " is NOT ready")
		if ready_players.has(_id):
			if ready_players[0] == _id:
				team_1.clear()
			if ready_players.size() > 1:
				if ready_players[1] == _id:
					team_2.clear()
					
			ready_players.erase(_id)
			
			emit_signal("is_ready", false)
	
	pass

remote func ready_failed():
	print("please wait for the next game")

remote func start_game():
	emit_signal("start_game")

remote func return_to_menu():
	ready_players.clear()
	team_1.clear()
	team_2.clear()
	Playerinfo.team = 0
	get_tree().change_scene("res://Scenes/GameMenu.tscn")
