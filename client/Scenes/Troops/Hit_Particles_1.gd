extends Particles

var pool

func go():
	print("hit")
	emitting = true
	$Timer.start()

func _on_Timer_timeout():
	get_parent().remove_child(self)
	pool.append(self)
