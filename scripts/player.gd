extends CharacterBody2D

@export var move_speed: float = 180.0

func _physics_process(_delta: float) -> void:
	if GameState.is_fishing:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var input_vector: Vector2 = Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = input_vector * move_speed
	move_and_slide()
