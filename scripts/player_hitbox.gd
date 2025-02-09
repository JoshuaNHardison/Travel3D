extends Area3D

signal body_detected(body : Node3D)

func _ready()->void:
	monitoring = false
	
	body_entered.connect(_on_body_entered)

func _on_body_entered(body : Node3D)->void:
	emit_signal("body_detected", body)
	#debug: who did i hit?
	#print("body detected: ", body.name)
