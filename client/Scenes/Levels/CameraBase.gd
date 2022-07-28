extends Spatial

onready var point_scene = preload("res://Scenes/Levels/Point.tscn")
onready var cursor_scene = preload("res://Scenes/Levels/cursor.tscn")

const MARGIN = 20
const CAM_SPEED = 40

const ray_length = 1000
onready var cam  = $Camera

var camera_pos = Vector3.ZERO
var hometeam = {}

var point = null
var cursor = null

var cam_freed = false


func _ready():
	set_network_master(get_tree().get_network_unique_id())
	hometeam = get_parent().hometeam
	
	cursor = cursor_scene.instance()
	add_child(cursor)


func _process(delta):
	if is_network_master():
		var m_pos = get_viewport().get_mouse_position()
		if cam_freed:
			var player_rot = 1
			if Playerinfo.team == 2:
				player_rot = -1
			if Input.is_action_pressed("w"):
				camera_pos.z -= CAM_SPEED * player_rot * delta
			if Input.is_action_pressed("s"):
				camera_pos.z += CAM_SPEED * player_rot * delta
			if Input.is_action_pressed("a"):
				camera_pos.x -= CAM_SPEED * player_rot * delta
			if Input.is_action_pressed("d"):
				camera_pos.x += CAM_SPEED * player_rot * delta
			
		global_transform.origin = lerp(global_transform.origin, camera_pos, .05)
			
		var result = raycast_from_mouse(m_pos,1)
		
		for troop in hometeam:
			if (hometeam[troop].is_selected or hometeam[troop].is_following) and result.has("position"):
				if hometeam[troop].is_selected:
					camera_pos = hometeam[troop].global_transform.origin
				#result.position.x = -result.position.x
				#result.position.z = -result.position.z
				hometeam[troop].look_at(result.position, Vector3.UP)
				hometeam[troop].rotation.x = 0
				hometeam[troop].rotation.z = 0
		
		if result.has("position"):
			cursor.global_transform.origin = result.position
			cursor.global_transform.origin.y +=1
		
		if Input.is_action_pressed("left_mouse"):
			left_action_1(m_pos)
		if Input.is_action_just_released("left_mouse"):
			left_action_2(m_pos)
		if Input.is_action_just_released("settings"):
			get_parent().get_node("HudOverlay/SettingsPanel").show()
			
	
func left_action_1(m_pos):
	var result = raycast_from_mouse(m_pos, 1)
	if result.size() == 0:
		return

	for troop in hometeam:
		if hometeam[troop].is_selected or hometeam[troop].is_following:
			hometeam[troop].fire_primary(result.position)


func left_action_2(m_pos):
	var result = raycast_from_mouse(m_pos, 1)
	if result.size() == 0:
		return

	if result.collider.name in hometeam:
		for troop in hometeam:
			hometeam[troop].is_selected = false
			hometeam[troop].is_following = false
		camera_pos = result.collider.global_transform.origin
		result.collider.is_selected = !result.collider.is_selected
		cam_freed = false


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		for troop in hometeam:
			hometeam[troop].is_selected = false
			hometeam[troop].is_following = true
		cam_freed = true


func raycast_from_mouse(m_pos, collisoin_mask):
	var ray_start = cam.project_ray_origin(m_pos)
	var ray_end = ray_start + cam.project_ray_normal(m_pos) * ray_length
	var space_state = get_world().direct_space_state
	return space_state.intersect_ray(ray_start, ray_end, [], collisoin_mask)
