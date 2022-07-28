extends Spatial

var bullet_scene = preload("res://Scenes/Troops/MGBullet.tscn")

var data
var cooldown_time = 0
var damage = 0
var accuracy = 0
var parent_name = ""
var level_node = null

var max_ammo = 100
var ammo_count = max_ammo
var clip = []
var bullet_pool = []

func init_weapon(_data, _name, _level):
	print(_level)
	data = _data
	cooldown_time = data["cooldown_speed"]
	damage = data["damage"]
	accuracy = data["accuracy"]
	parent_name = _name
	level_node = _level
	
	for b in range(max_ammo):
		var bul = bullet_scene.instance()
		bul.get_node("RayCast").set_collision_mask_bit(Playerinfo.team+1, false)
		bul.name = parent_name + "_ar" + str(b)
		bul.pool = bullet_pool
		bullet_pool.append(bul)
	#print(bullet_pool)

sync func shoot(pos):
	if bullet_pool.size() <= 0:
		return
	var b = bullet_pool.pop_back()
	print("boom! #", b, "  ", level_node)
	level_node.add_child(b)
	b.global_transform = $MuzzlePosition.global_transform
	b.fire(pos, global_transform.origin)
	
