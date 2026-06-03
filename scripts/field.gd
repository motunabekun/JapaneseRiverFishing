extends Node2D

var player_in_fishing_area: bool = false

@onready var fishing_prompt: Label = $UI/FishingPrompt

var cast_direction: Vector2 = Vector2.UP
var cast_distance: float = 120.0

@onready var cast_line: Line2D = $CastLine

enum FishingMode {
	NONE,
	AIMING,
	CASTED
}

var fishing_mode: FishingMode = FishingMode.NONE
var cast_target_position: Vector2 = Vector2.ZERO

@onready var cast_target: Sprite2D = $CastTarget
@onready var bite_timer: Timer = $BiteTimer

var fish_hooked: bool = false

var line_tension: float = 50.0
var fish_distance: float = 100.0

const MIN_TENSION: float = 10.0
const MAX_TENSION: float = 90.0

@onready var fight_bar: ProgressBar = $UI/FightBar
@onready var distance_bar: ProgressBar = $UI/DistanceBar

@onready var record_panel: Panel = $UI/RecordPanel
@onready var record_label: Label = $UI/RecordPanel/RecordLabel
@onready var money_label: Label = $UI/MoneyLabel
@onready var tension_label: Label = $UI/TensionLabel
@onready var distance_label: Label = $UI/DistanceLabel

func _ready() -> void:
	fishing_prompt.visible = false
	cast_line.visible = false
	cast_target.visible = false
	fight_bar.visible = false
	fight_bar.value = 50
	distance_bar.visible = false
	distance_bar.value = 100
	record_panel.visible = false
	tension_label.visible = false
	distance_label.visible = false
	update_money_label()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_record"):
		toggle_record_panel()
	
	if Input.is_action_just_pressed("sell_fish"):
		sell_all_fish()
	
	if fish_hooked:
		update_fight(_delta)
		return

	if GameState.fish_biting:
		if Input.is_action_just_pressed("action"):
			GameState.end_bite()

			fish_hooked = true

			line_tension = 50.0
			fish_distance = 100.0

			fight_bar.visible = true
			distance_bar.visible = true

			fight_bar.value = line_tension
			distance_bar.value = fish_distance
			
			tension_label.visible = true
			distance_label.visible = true

			fishing_prompt.text = "魚が掛かった！ Iキーでテンション調整"

			print("魚が掛かった！")
			return

	if GameState.is_fishing:
		if fishing_mode == FishingMode.AIMING:
			update_cast_direction()

	if player_in_fishing_area:
		if Input.is_action_just_pressed("action"):
			if not GameState.is_fishing:
				start_fishing()
			elif fishing_mode == FishingMode.AIMING:
				cast_line_to_target()
			elif fishing_mode == FishingMode.CASTED:
				end_fishing()


func start_fishing() -> void:
	GameState.start_fishing()
	fishing_mode = FishingMode.AIMING

	fishing_prompt.visible = true
	fishing_prompt.text = "方向を決めてAボタンでキャスト"

	cast_line.visible = true
	cast_target.visible = false

	print("釣り開始！")


func end_fishing() -> void:
	GameState.end_fishing()
	fishing_mode = FishingMode.NONE

	fish_hooked = false

	fishing_prompt.visible = true
	fishing_prompt.text = "Aボタンで釣り開始"

	cast_line.visible = false
	cast_target.visible = false
	fight_bar.visible = false
	tension_label.visible = false
	distance_label.visible = false

	bite_timer.stop()
	
	fish_hooked = false
	line_tension = 50.0
	fish_distance = 100.0

	fight_bar.visible = false
	distance_bar.visible = false

	print("釣り終了")


func _on_fishing_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_fishing_area = true
		fishing_prompt.visible = true
		fishing_prompt.text = "Aボタンで釣り開始"
		print("釣りエリアに入った")


func _on_fishing_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_fishing_area = false
		GameState.end_fishing()
		fishing_prompt.visible = false
		print("釣りエリアから出た")

func update_cast_direction() -> void:
	var direction: Vector2 = Input.get_vector(
		"look_left",
		"look_right",
		"look_up",
		"look_down"
	)

	if direction.length() > 0.2:
		cast_direction = direction.normalized()

	var player: Node2D = $Player
	var start_pos: Vector2 = player.global_position
	var end_pos: Vector2 = start_pos + cast_direction * cast_distance

	cast_line.clear_points()
	cast_line.add_point(start_pos)
	cast_line.add_point(end_pos)

func cast_line_to_target() -> void:
	var player: Node2D = $Player

	cast_target_position = player.global_position + cast_direction * cast_distance

	cast_target.global_position = cast_target_position
	cast_target.visible = true

	cast_line.clear_points()
	cast_line.add_point(player.global_position)
	cast_line.add_point(cast_target_position)

	fishing_mode = FishingMode.CASTED
	fishing_prompt.text = "キャスト！ Aボタンで終了"

	print("キャスト地点: ", cast_target_position)
	
	bite_timer.start()
	fishing_prompt.text = "魚を待っています..."


func _on_bite_timer_timeout() -> void:
	if randi() % 100 < 90:
		GameState.start_bite()
		fishing_prompt.text = "アタリ！Aボタンで合わせろ！"
		print("アタリ！")
	else:
		fishing_prompt.text = "魚は来なかった..."
		
func update_fight(delta: float) -> void:
	if Input.is_action_pressed("look_up"):
		line_tension += 45.0 * delta
	else:
		line_tension -= 25.0 * delta

	line_tension = clamp(line_tension, 0.0, 100.0)

	if line_tension < MIN_TENSION:
		fish_escape("テンションが低すぎてバレた！")
		return

	if line_tension > MAX_TENSION:
		fish_escape("テンションが高すぎてラインブレイク！")
		return

	if line_tension >= 40.0 and line_tension <= 80.0:
		fish_distance -= 20.0 * delta
	else:
		fish_distance += 10.0 * delta

	fish_distance = clamp(fish_distance, 0.0, 100.0)

	fight_bar.value = line_tension
	distance_bar.value = fish_distance

	if fish_distance <= 0.0:
		catch_fish()

func catch_fish() -> void:
	var caught_fish: Dictionary = FishDatabase.get_random_fish()

	fish_hooked = false
	fight_bar.visible = false
	distance_bar.visible = false
	tension_label.visible = false
	distance_label.visible = false

	if caught_fish.is_empty():
		fishing_prompt.text = "魚GET！ でも魚データがありません"
		print("魚データがありません")
		return

	CatchRecord.add_catch(caught_fish)

	fishing_prompt.text = "魚GET！ %s %.1fcm %.1fg  Aボタンで終了" % [
		caught_fish["name"],
		caught_fish["size"],
		caught_fish["weight"]
	]

	print("魚GET！")
	print(caught_fish)
	print(CatchRecord.get_records())

func toggle_record_panel() -> void:
	record_panel.visible = !record_panel.visible

	if record_panel.visible:
		update_record_panel()
		
func update_record_panel() -> void:
	var text := "=== 釣果一覧 ===\n\n"
	var records: Dictionary = CatchRecord.get_records()
	for fish_id in records:
		var fish: Dictionary = records[fish_id]
		text += "%s\n" % fish["name"]
		text += "匹数: %d\n" % fish["count"]
		text += "最大サイズ: %.1fcm\n" % fish["max_size"]
		text += "最大重量: %.1fg\n\n" % fish["max_weight"]

	record_label.text = text

func update_money_label() -> void:
	money_label.text = "所持金: %d円" % GameState.money

func sell_all_fish() -> void:
	var history: Array[Dictionary] = CatchRecord.get_history()

	if history.is_empty():
		fishing_prompt.visible = true
		fishing_prompt.text = "売れる魚がありません"
		return

	var total_price: int = 0

	for fish: Dictionary in history:
		total_price += int(fish["sell_price"])

	GameState.add_money(total_price)

	history.clear()

	fishing_prompt.visible = true
	fishing_prompt.text = "魚を売却しました！ +%d円" % total_price

	update_money_label()
	update_record_panel()

	print("売却額: ", total_price)

func fish_escape(message: String) -> void:
	fish_hooked = false

	fight_bar.visible = false
	distance_bar.visible = false
	tension_label.visible = false
	distance_label.visible = false

	fishing_prompt.text = message + " Aボタンで終了"

	print(message)
