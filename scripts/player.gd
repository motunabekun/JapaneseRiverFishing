extends CharacterBody2D

@export var move_speed: float = 180.0


# _physics_processは物理フレームごとに呼ばれます。
# CharacterBody2Dの移動はここで処理すると安定します。
func _physics_process(_delta: float) -> void:
	# 釣り中はプレイヤーを動けない状態にします。
	if GameState.is_fishing:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# project.godotで設定した入力名から、上下左右の入力方向をまとめて取得します。
	var input_vector: Vector2 = Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	# velocityを設定してからmove_and_slide()を呼ぶと、Godotが衝突を考慮して動かします。
	velocity = input_vector * move_speed
	move_and_slide()
