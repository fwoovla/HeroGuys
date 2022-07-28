extends Node2D

onready var username = $Username

func _ready():
	OS.window_fullscreen = true

func _on_Quit_pressed():
	get_tree().quit()


func _on_FindServer_pressed():
	if username.text == "":
		return
		
	Network.ip_address = Network.external_ip
	Network.username = username.text
	Network.connect_to_server()
	


func _on_Settings_pressed():
	$SettingsPanel.show()


func _on_Settings_Back_pressed():
	$SettingsPanel.hide()


func _on_LocalServer_pressed():
	if username.text == "":
		return
	Network.ip_address = Network.local_ip
	Network.username = username.text
	Network.connect_to_server()
