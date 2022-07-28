extends Spatial

onready var raycast = get_node("RayCast")
onready var tween = get_node("Tween")

var team_num = 0
var speed = Gamesettings.weapons_data[4]["bullet_speed"]
var velocity
var pool # array to return the bullet to

func _on_Tween_tween_all_completed():
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var col = raycast.get_collider()
		print(col)
		if col.has_method("take_damage") and !col.is_in_group(str(team_num)):
			col.take_damage(Gamesettings.weapons_data[1]["damage"])
			
	get_parent().remove_child(self)
	pool.append(self)
	#print(pool)


func fire(_pos):
	#$testingtimer.start(.5)
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var pos = raycast.get_collision_point()
		#print(pos)
		var time = global_transform.origin.distance_to(pos) / speed
		tween.interpolate_property(self, "global_transform:origin", global_transform.origin, pos, time, Tween.TRANS_LINEAR)
		tween.start()


func _on_Timeout_timeout():
	#print("returning to pool")
	get_parent().remove_child(self)
	pool.append(self)
	#print(pool)
