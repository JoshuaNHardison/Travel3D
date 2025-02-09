extends CharacterBody3D
class_name LocalPlayer

#Movement
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


#Attack
var is_attacking : bool = false
@export var attack_cooldown : float = 0.5
var can_attack : bool = true
@export var damage_amount = 50


#Nodes
@onready var hitbox : Area3D = $Hitbox
@onready var cooldown_timer : Timer = $CooldownTimer
@onready var local_camera = $LocalCamera
@onready var player_camera : Camera3D = $LocalCamera/PlayerCamera


func _ready():
	hitbox.body_detected.connect(_on_Hitbox_body_entered)


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	#var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	var direction = get_direction(input_dir)
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		rotation.y = atan2(-direction.x, -direction.z)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

#get camera
#use its positive z direction and base the movement on that
func get_direction(input_dir : Vector2)->Vector3:
	var camera_forward = player_camera.global_transform.basis.z
	var camera_xy = player_camera.global_transform.basis.x
	camera_forward.normalized()
	camera_xy.normalized()
	var direction = (camera_forward * input_dir.y + camera_xy * input_dir.x).normalized()
	return direction

func _input(event : InputEvent)->void:
	if event.is_action_pressed("attack") and can_attack:
		attack()


func attack()->void:
	is_attacking = true
	can_attack = false
	hitbox.monitoring = true
	cooldown_timer.start(attack_cooldown)


func _on_Hitbox_body_entered(body):
	if body.has_method("take_damage"):
		#debug: who did i hit?
		#print("hitbox detected: ", body.name)
		body.take_damage(damage_amount)


func _on_cooldownTimer_timeout():
	can_attack = true
	hitbox.monitoring = false
