extends Node2D

onready var playerlist = $ReadyPlayers/ItemList


func _ready():
	Network.connect("start_game", self, "start_game")
	Network.connect("update_players", self, "update_players_list")
	Network.connect("is_ready", self, "queued_for_game")
	$Countdown.connect("game_ready", self, "game_ready")
	$Countdown.hide()
	update_players_list()

func update_players_list():
	playerlist.clear()
	for player in Network.players:
		playerlist.add_item(Network.players[player]["username"])

func queued_for_game(is_ready : bool):
	if is_ready:
		$Ready/Label.modulate = Color.red
	else:
		$Ready/Label.modulate = Color.white
	
func _on_Quit_pressed():
	get_tree().quit()

func _on_Ready_toggled(button_pressed):
	if button_pressed:
		Network.rpc_id(1, "ready_request", true, Playerinfo.assemble_trooops())
	else:
		Network.rpc_id(1, "ready_request", false, {})
		
		$Countdown.stop()

func start_game():
	$Countdown.show()
	$Countdown.start()

func game_ready():
	if Network.ready_players.has(get_tree().get_network_unique_id()):
		get_tree().change_scene("res://Scenes/Levels/TestLevel.tscn")
		
