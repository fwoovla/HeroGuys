extends Spatial

var bullet_scene = preload("res://Scenes/Troops/MGBullet.tscn")

onready var cooldowntimer = $CooldownTimer

var data
var cooldown_time = 0
var damage = 0
var accuracy = 0
var can_shoot = true
var parent_name = ""
var level_node = null

var max_ammo = 100
var ammo_count = max_ammo
var clip = []
var bullet_pool = []

func init_weapon(_data, _name, _level, _team_num):
	print(_level)
	data = _data
	cooldown_time = data["cooldown_speed"]
	damage = data["damage"]
	accuracy = data["accuracy"]
	parent_name = _name
	level_node = _level

	for b in range(max_ammo):
		var bul = bullet_scene.instance()
		bul.team_num = _team_num
		bul.name = parent_name + "_mg" + str(b)
		bul.pool = bullet_pool
		bullet_pool.append(bul)

remote func shoot_request(pos):
	if can_shoot:
		can_shoot = false
		rpc("shoot", pos)
		cooldowntimer.start(cooldown_time)
		
sync func shoot(pos):
	var b = bullet_pool.pop_back()
	print("boom! #", b, "  ", level_node)
	level_node.add_child(b)
	b.global_transform = $MuzzlePosition.global_transform
	b.fire(pos)
	
func _on_CooldownTimer_timeout():
	can_shoot = true
