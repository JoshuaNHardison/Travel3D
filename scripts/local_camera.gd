extends Node
class_name SoulsCamera

@export var look_at : Node3D
var root_player : LocalPlayer
@export var player : CharacterBody3D

@onready var camera = $PlayerCamera
@onready var focus_point = $FocusPoint
@onready var camera_nest = $CameraNest
@onready var focus_point_tween : Tween
@onready var is_target_locked : bool = false

@export var mouse_sensitivity : float = 0.1
@export var vertical_angle_limit: Vector2 = Vector2(-10,30)

var offset : Vector3 = Vector3(0, 0, -5)


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	focus_point_tween = create_tween()

func _process(delta):
	if player:
		# focus_point.global_position = player.global_position
		update_camera_position()
		update_focus_point_position(delta)


func update_focus_point_position(delta):
	if focus_point_tween:
		focus_point_tween.kill()
	focus_point_tween = create_tween()
	focus_point_tween.tween_property(
	 	focus_point,
	 	"global_position",
	 	player.global_position,
	 	0.5
	 ).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
	#if its within a certain distance - stop that shit you bitcch
	#focus_point.global_position += (focus_point.position.direction_to(player.position)) * delta * 2


func _input(event : InputEvent):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var mouse_delta = event.screen_relative
		pan_camera(mouse_delta)

func rotate_camera():
	camera.look_at(focus_point.position)


func pan_camera(mouse_delta : Vector2):
	# Horizontal rotation (around Y-axis, relative to FocusPoint)
	camera_nest.rotate_object_local(Vector3.UP, deg_to_rad(-mouse_delta.x * mouse_sensitivity))
	
	# Vertical rotation (around X-axis, clamped to limits)
	var current_vertical_angle = camera_nest.rotation_degrees.x
	var new_vertical_angle = current_vertical_angle - mouse_delta.y * mouse_sensitivity
	camera_nest.rotation_degrees.x = clamp(new_vertical_angle, vertical_angle_limit.x, vertical_angle_limit.y)
	
	# Update camera position based on new rotation
	update_camera_position()


func update_camera_position():
 	# Calculate the new position of the CameraNest based on its rotation
	var forward = -camera_nest.transform.basis.z  # Forward direction of the CameraNest
	camera_nest.global_position = focus_point.global_position + forward * offset.length()
	# Ensure the camera looks at the FocusPoint
	camera.global_position = camera_nest.global_position
	rotate_camera()
