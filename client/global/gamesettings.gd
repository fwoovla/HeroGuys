extends Node



var lighting = true
var shadows = true
var fullscreen = true

var hit_1_scene = preload("res://Scenes/Troops/Hit_Particles_1.tscn")
var hit_pool = []


var auto_rifle_data = {
	"name":"Auto Rifle",
	"damage":10,
	"cooldown_speed":.2,
	"bullet_speed":300,
	"accuracy":.2,
}
var shotgun_data = {
	"name":"Shotgun",
	"damage":30,
	"cooldown_speed":.5,
	"bullet_speed":250,
	"accuracy":.2,
}
var machine_gun_data = {
	"name":"Machine Gun",
	"damage":4,
	"cooldown_speed":.09,
	"bullet_speed":300,
	"accuracy":.2,
}
var sniper_rifle_data = {
	"name":"Sniper Rifle",
	"damage":90,
	"cooldown_speed":1,
	"bullet_speed":400,
	"accuracy":.2,
}

var weapons_data = {
	1:auto_rifle_data,
	2:shotgun_data,
	3:machine_gun_data,
	4:sniper_rifle_data
}


var auto_rifle_scene = preload("res://Scenes/Troops/Autorifle.tscn")
var shotgun_scene = preload("res://Scenes/Troops/Shotgun.tscn")
var machine_gun_scene = preload("res://Scenes/Troops/MachineGun.tscn")
var sniper_rifle_scene = preload("res://Scenes/Troops/SniperRifle.tscn")

var weapons_scenes = {
	1:auto_rifle_scene,
	2:shotgun_scene,
	3:machine_gun_scene,
	4:sniper_rifle_scene
}

var soldier_data = {
	"name":"Soldier",
	"speed":18,
	"health":220,
	"portrait":1
}
var scout_data = {
	"name":"Scout",
	"speed":25,
	"health":130,
	"portrait":2
}
var heavy_data = {
	"name":"Heavy",
	"speed":15,
	"health":350,
	"portrait":3
}
var sniper_data = {
	"name":"Sniper",
	"speed":22,
	"health":150,
	"portrait":4
}

var troop_data = {
	1:soldier_data,
	2:scout_data,
	3:heavy_data,
	4:sniper_data
}

var portraits = {}


func _ready():
	preload_assets()
	
	for hit in range(2000):
		var h = hit_1_scene.instance()
		hit_pool.append(h)
		h.pool = hit_pool

func preload_assets():	
	#portraits
	var p1 = preload("res://assets/sprites/portrait_1.png")
	var p2 = preload("res://assets/sprites/portrait_2.png")
	var p3 = preload("res://assets/sprites/portrait_3.png")
	var p4 = preload("res://assets/sprites/portrait_4.png")
	portraits = {1:p1, 2:p2, 3:p3, 4:p4}


