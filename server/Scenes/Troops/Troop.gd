extends KinematicBody

onready var tween = $MovementTween

var speed = 50
var health = 100

puppet var puppet_transform:Transform
puppet var puppet_rot
puppet var puppet_speed = 0
puppet var puppet_rotation:Vector3
puppet var puppet_velocity:Vector3
var velocity:Vector3
var data = {}

var path = []
var path_index = 0
var nav := Navigation.new()

func init_troop(_data, _team_num):
	data = _data
	add_to_group(str(_team_num))
	var weapon = Gamesettings.weapons_scenes[data["portrait"]].instance()
	$WeaponPosition.add_child(weapon)
	weapon.init_weapon(Gamesettings.weapons_data[data["portrait"]], name, get_parent(), _team_num)

func update_puppet(t:Vector3, rx:float, ry:float, rz:float, speed:bool, health:int):
	# Interpolate translation and rotation
	tween.interpolate_property(self, "translation", translation, t, Network.HOST_RATE, Tween.TRANS_LINEAR)
	tween.interpolate_property(self, "transform:basis", transform.basis, Basis(Vector3(rx, ry, rz)), Network.HOST_RATE, Tween.TRANS_LINEAR)
	tween.start()
	health = health


func take_damage(damage):
	health -= damage
	print("health: ", health)
	rpc("client_take_damage", damage)
