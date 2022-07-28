extends Panel


func _ready():
	pass


func _on_Fullscreen_toggled(button_pressed):
	Gamesettings.fullscreen = button_pressed
	OS.window_fullscreen = button_pressed


func _on_Lighting_toggled(button_pressed):
	Gamesettings.lighting = button_pressed


func _on_Shadows_toggled(button_pressed):
	Gamesettings.shadows = button_pressed

