extends CharacterBody3D

@export var max_health : int = 100
@export var move_speed : float = 2.0
@export var damage : int = 10

var health : int
var is_dead : bool = false

@onready var player = get_tree().get_root().get_node("Main/Player")

func _ready():
	health = max_health

func _process(delta):
	if is_dead:
		return

	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * move_speed
		apply_floor_snap()
		move_and_slide()

func take_damage(amount : int)->void:
	if is_dead:
		return
	health -= amount
	#debug: health remaining after attack
	#print("health: ", health)
	
	if health <= 0:
		die()

func die()->void:
	is_dead = true
	print("enemy died")
	queue_free()
