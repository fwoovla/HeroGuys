extends Spatial

onready var raycast = get_node("RayCast")
onready var tween = get_node("Tween")
onready var tail = get_node("Tail")

var start_pos = Vector3.ZERO
var end_pos = Vector3.ZERO
var speed = Gamesettings.weapons_data[3]["bullet_speed"]
var velocity
var pool# array to return the bullet to

func _ready():
	set_process(false)

func _on_Tween_tween_all_completed():
	$Particles.emitting = false
	var hit = Gamesettings.hit_pool.pop_back()
	get_parent().add_child(hit)
	hit.global_transform = global_transform
	hit.go()
	print("returnin to pool")
	get_parent().remove_child(self)
	pool.append(self)
	#print(pool)

func _process(delta):
	tail.clear()
#	var m = SpatialMaterial.new()
#	tail.set_material_override(m)
	tail.clear()
	tail.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	tail.add_vertex(start_pos)
	tail.add_vertex(global_transform.origin)
	tail.end()
#	tail.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
#	tail.end()

func fire(_pos, _start_pos):
	#set_process(true)
	start_pos = _start_pos
	raycast.force_raycast_update()
	if raycast.is_colliding():
		end_pos = raycast.get_collision_point()
		#print(end_pos)
		var time = global_transform.origin.distance_to(end_pos) / speed
		tween.interpolate_property(self, "global_transform:origin", global_transform.origin, end_pos, time, Tween.TRANS_LINEAR)
		tween.start()


func _on_Timeout_timeout():
	print("returnin to pool")
	get_parent().remove_child(self)
	pool.append(self)
	#print(pool)


func _on_Particles_tree_exited():
	$Particles.emitting = false


func _on_Tween_tween_step(object, key, elapsed, value):
	if elapsed > .04:
		$Particles.emitting = true

