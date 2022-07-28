extends TextureRect

var time_remaining = 5

signal game_ready

func _ready():
	Network.connect("update_players", self, "update_ready")

func update_ready():
	for player in Network.players:
		if !Network.ready_players.has(player):
			$Timer.stop()
			$AnimationPlayer.play("hide")
	pass

func start():
	$Label.text = str(time_remaining)
	$Timer.start()
	$AnimationPlayer.play("countdown")

func stop():
	$Label.text = str(time_remaining)
	$Timer.stop()
	$AnimationPlayer.play("hide")
	
func _on_Timer_timeout():
	time_remaining -= 1
	$Label.text = str(time_remaining)
	
	if time_remaining == 0:
		emit_signal("game_ready")
