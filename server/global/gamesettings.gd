extends Node

var auto_rifle_data = {
	"name":"Auto Rifle",
	"damage":10,
	"cooldown_speed":.2,
	"bullet_speed":300,
	"accuracy":.2,
}
var shotgun_data = {
	"name":"Shotgun",
	"damage":10,
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
	"damage":50,
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
