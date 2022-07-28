extends KinematicBody

onready var tween = $MovementTween
onready var avoidarea = $AvoidArea
var team_colors = [Color.cyan, Color.magenta]

var is_hometeam = false
var teammates = {} # nodes
var health = 100
var speed = 0
var select_speed = 5
var data : = {}
#var path = []
#var path_index = 0
#var nav := Navigation.new()
var is_selected = false setget set_selected
var is_following = false setget set_following
var follow_point = Vector3.ZERO
var velocity = Vector3.ZERO
var av = Vector2.ZERO  # Avoidance vector.
var avoid_weight = 0.2  # How strongly to avoid other units.
var target_radius = 5  # Stop when this close to target.
var can_move = false
var troop_name = ""
var weapon = null # node

func init_troop(_data:Dictionary, _team_num: int, _is_hometeam: bool, _nav :Navigation):
	data = _data
	#nav = _nav
	var mat = SpatialMaterial.new()
	mat.albedo_color = team_colors[_team_num - 1]  #                           <----  >:(  not good indexing
	$Body/Visor.material_override = mat
	$SelectedSprite.hide()
	is_hometeam = _is_hometeam
	if is_hometeam:
		add_to_group("hometeam")
	else:
		add_to_group("awayteam")
	set_collision_layer_bit(_team_num+1, true)
	set_collision_mask_bit(_team_num+1, false)
	
	health = data["health"]
	speed = data["speed"]
	#troop_name = data["name"]
	
	var w = Gamesettings.weapons_scenes[data["portrait"]].instance()
	w.init_weapon(Gamesettings.weapons_data[data["portrait"]], name, get_parent())
	$WeaponPosition.add_child(w)
	weapon = w
	
	set_network_master(Network.ready_players[_team_num - 1])  #                           <----  >:(  not good indexing here either


func _physics_process(delta):
	#velocity = Vector3.ZERO
	if is_network_master():
		if !is_following and !is_selected:
			velocity = Vector3.ZERO

		if is_selected and can_move: # or is_following:
			velocity = get_input()
			for troop in get_tree().get_nodes_in_group("hometeam"):
				if troop.is_following:
					troop.follow_point = global_transform.origin

		if is_following:
			velocity = (follow_point - global_transform.origin).normalized()
			if global_transform.origin.distance_to(follow_point) < 5:
				velocity = Vector3.ZERO

		if !is_on_floor():
			velocity.y = -.1
		
		if !is_selected:
			av = avoid()
		velocity = (velocity + av * avoid_weight)
		
		if is_selected:
			move_and_slide(velocity.normalized() * (speed + select_speed), Vector3.UP)
		else:
			move_and_slide(velocity.normalized() * speed, Vector3.UP)

func get_input():
	var dir = Vector3.ZERO
	
	if Input.is_action_pressed("w"):
		dir -= transform.basis.z
	if Input.is_action_pressed("s"):
		dir += transform.basis.z
	if Input.is_action_pressed("a"):
		dir -= transform.basis.x
	if Input.is_action_pressed("d"):
		dir += transform.basis.x
	if Input.is_action_just_pressed("ui_select") and is_selected:

		if $CommandArea.visible == false:
			$CommandArea.monitoring = true
			$CommandArea.show()
			$CommandArea/Sprite3D.show()
			$CommandArea/AnimationPlayer.play("pulse")
			$CommandArea/CollisionShape/AnimationPlayer.play("pulse")
			
		else:		
			$CommandArea.hide()
			$CommandArea.monitoring = false
			$CommandArea/Sprite3D.hide()
			$CommandArea/AnimationPlayer.stop()
			for troop in get_tree().get_nodes_in_group("hometeam"):
				troop.is_following = false
	return dir.normalized()

func avoid():
	# Calculates avoidance vector based on nearby units.
	var result = Vector3.ZERO
	var neighbors = avoidarea.get_overlapping_bodies()
	if !neighbors:
		return result
	for n in neighbors:
		if n.is_in_group("hometeam"):
			result += n.global_transform.origin.direction_to(global_transform.origin)
	result /= neighbors.size()
	return result.normalized()

func set_following(value):
	if is_network_master() and !is_selected:
		is_following = value
		av = Vector3.ZERO

func set_selected(value):
	if is_network_master():

		is_selected = value
		#print(value)
		
		if is_selected:
			can_move = true
			$CanvasLayer/InfoPanel/Name.text = name
			$CanvasLayer/InfoPanel/Health.text = str(health)
			$SelectedSprite.show()
			$SelectedSprite/AnimationPlayer.play("sekected")
			$CanvasLayer/InfoPanel/AnimationPlayer.play("up")
			#$CommandArea/Sprite3D.show()
			#$CommandArea/AnimationPlayer.play("pulse")
		else:
			can_move = false
			$SelectedSprite.hide()
			$SelectedSprite/AnimationPlayer.stop()
			$CanvasLayer/InfoPanel/AnimationPlayer.play("down")
			$CommandArea.hide()
			$CommandArea.monitoring = false
			$CommandArea/Sprite3D.hide()
			$CommandArea/AnimationPlayer.stop()

func rotate_to_target(target, delta):
	#print(target)
	#print("last state is :" + str(state))
	var global_pos = global_transform.origin
	var wtransform = global_transform.looking_at(Vector3(target.x, global_transform.origin.y, target.z),Vector3(0,1,0))
	var wrotation = Quat(global_transform.basis).slerp(Quat(wtransform.basis), 20 * delta)
	return Transform(Basis(wrotation), global_transform.origin)
	


func update_puppet(gtrans, _translation:Vector3, rx:float, ry:float, rz:float, speed:bool, health:int):
	# Interpolate translation and rotation
	#print("updating: ", name)

	tween.interpolate_property(self, "translation", translation, _translation, Network.HOST_RATE, Tween.TRANS_LINEAR)
	tween.interpolate_property(self, "transform:basis", transform.basis, Basis(Vector3(rx, ry, rz)), Network.HOST_RATE, Tween.TRANS_LINEAR)
	tween.interpolate_property(self, "global_transform", global_transform, gtrans, Network.HOST_RATE, Tween.TRANS_LINEAR)
	
	tween.start()
	health = health


func _on_Troop_mouse_entered():
	return
	if is_in_group("hometeam") and !is_selected:
		$CanvasLayer/InfoPanel/Name.text = name
		$CanvasLayer/InfoPanel/Health.text = str(health)
		print(health)
		$CanvasLayer/InfoPanel/AnimationPlayer.play("up")


func _on_Troop_mouse_exited():
	return
	if is_in_group("hometeam") and !is_selected:
		$CanvasLayer/InfoPanel/AnimationPlayer.play("down")


func _on_CommandArea_body_entered(body):
	if body.is_in_group("hometeam"):
		body.is_following = true


func fire_primary(pos):
	weapon.rpc_id(1, "shoot_request", pos)


remote func client_take_damage(damage):
	health -= damage
	print(health)
