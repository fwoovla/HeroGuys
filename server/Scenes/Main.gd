extends Node2D

var game_level = "res://Scenes/Levels/TestLevel.tscn"

func _ready():
	print(str(Network.READY_MAX), " Player game")
	
	Network.connect("start_game", self, "start_game")
	if get_tree().is_network_server():
		return
	Network.start_server()
	pass


func start_game():
	get_tree().change_scene(game_level)
