extends Node

# FishManagerは将来Autoloadに登録して使う想定の、魚個体群の管理クラスです。
# Step 1では既存MVPからはまだ呼ばず、土台だけを用意しています。
const FISH_DATA_PATH: String = "res://data/fish_data.json"
const SPAWN_DATA_PATH: String = "res://data/fish_spawn_data.json"

var fish_instances: Array[Dictionary] = []
var spawn_rules: Array[Dictionary] = []
var species_data: Dictionary = {}
var next_instance_number: int = 1


## 魚種データとスポーンデータを読み込み、初期魚個体を生成します。
## 引数: なし
## 戻り値: なし
func initialize_fish() -> void:
	fish_instances.clear()
	next_instance_number = 1

	_load_species_data()
	_load_spawn_data()

	for spawn_rule: Dictionary in spawn_rules:
		var initial_count: int = int(spawn_rule.get("initial_count", 0))
		var species_id: String = String(spawn_rule.get("species_id", ""))

		for _index: int in range(initial_count):
			var spawn_position: Vector2 = _get_random_spawn_position(spawn_rule)
			create_fish_instance(species_id, spawn_position)


## 指定地点の周辺にいる未捕獲の魚を検索します。
## 引数: search_position 検索中心座標、radius 検索半径
## 戻り値: 最寄りの魚個体データ。見つからない場合は空のDictionary
func get_fish_near_position(search_position: Vector2, radius: float) -> Dictionary:
	var nearest_fish: Dictionary = {}
	var nearest_distance: float = radius

	for fish: Dictionary in fish_instances:
		if bool(fish.get("is_caught", false)):
			continue

		var fish_position: Vector2 = _read_position(fish.get("position", Vector2.ZERO))
		var distance: float = search_position.distance_to(fish_position)

		if distance <= nearest_distance:
			nearest_distance = distance
			nearest_fish = fish

	return nearest_fish


## 指定IDの魚個体を捕獲済みにします。
## 引数: fish_id 捕獲済みにする魚個体ID
## 戻り値: なし
func mark_fish_caught(fish_id: String) -> void:
	for index: int in range(fish_instances.size()):
		var fish: Dictionary = fish_instances[index]
		if String(fish.get("id", "")) == fish_id:
			fish["is_caught"] = true
			fish_instances[index] = fish
			return


## 魚種IDと位置から新しい魚個体を生成します。
## 引数: species_id 魚種ID、spawn_position 生成位置
## 戻り値: 生成した魚個体データ。魚種がない場合は空のDictionary
func create_fish_instance(species_id: String, spawn_position: Vector2) -> Dictionary:
	if species_id.is_empty() or not species_data.has(species_id):
		return {}

	var species: Dictionary = species_data[species_id]
	var now: float = Time.get_unix_time_from_system()
	var min_size: float = float(species.get("min_size", 10.0))
	var max_size: float = float(species.get("max_size", min_size))
	var size: float = snapped(randf_range(min_size, max_size), 0.1)
	var base_weight: float = float(species.get("base_weight", 100.0))
	var weight: float = snapped(size / max_size * base_weight, 0.1)

	# FishInstanceで値を整えてからDictionary化し、一覧に保存します。
	var fish_instance: FishInstance = FishInstance.new()
	var instance_data: Dictionary = {
		"id": "%s_%04d" % [species_id, next_instance_number],
		"species_id": species_id,
		"species_name": String(species.get("name", species_id)),
		"size": size,
		"weight": weight,
		"age_days": randf_range(30.0, 365.0),
		"growth_rate": randf_range(0.01, 0.08),
		"stamina": 100.0,
		"power": max(10.0, size),
		"position": spawn_position,
		"is_caught": false,
		"spawn_time": now,
		"last_update_time": now
	}

	fish_instance.setup(instance_data)
	next_instance_number += 1

	var fish_data: Dictionary = fish_instance.to_dict()
	fish_instances.append(fish_data)
	return fish_data


## 魚種ごとの生存数が不足している場合に魚個体を補充します。
## 引数: なし
## 戻り値: なし
func replenish_if_needed() -> void:
	for spawn_rule: Dictionary in spawn_rules:
		var species_id: String = String(spawn_rule.get("species_id", ""))
		var min_count: int = int(spawn_rule.get("min_count", 0))
		var max_count: int = int(spawn_rule.get("max_count", min_count))
		var current_count: int = _count_available_fish(species_id)

		while current_count < min_count and current_count < max_count:
			var spawn_position: Vector2 = _get_random_spawn_position(spawn_rule)
			var fish: Dictionary = create_fish_instance(species_id, spawn_position)
			if fish.is_empty():
				break
			current_count += 1


## 管理中の魚個体一覧を返します。
## 引数: なし
## 戻り値: 魚個体データDictionaryの配列
func get_all_fish() -> Array:
	return fish_instances.duplicate(true)


func _load_species_data() -> void:
	# 現段階では既存MVPのfish_data.jsonを魚種データとして再利用します。
	species_data.clear()

	var loaded_data: Array[Dictionary] = _load_json_array(FISH_DATA_PATH)
	for species: Dictionary in loaded_data:
		var species_id: String = String(species.get("id", ""))
		if not species_id.is_empty():
			species_data[species_id] = species


func _load_spawn_data() -> void:
	# どの魚種をどの場所に何匹出すか、というスポーン設定を読み込みます。
	spawn_rules = _load_json_array(SPAWN_DATA_PATH)


func _load_json_array(path: String) -> Array[Dictionary]:
	# GodotのJSON.parse_string()はVariantを返すため、Array/Dictionaryか確認してから使います。
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("JSONを読み込めませんでした: %s" % path)
		return []

	var text: String = file.get_as_text()
	var parsed_data: Variant = JSON.parse_string(text)
	if not (parsed_data is Array):
		push_error("JSONの配列形式が間違っています: %s" % path)
		return []

	var result: Array[Dictionary] = []
	var parsed_array: Array = parsed_data as Array
	for item: Variant in parsed_array:
		if item is Dictionary:
			var item_data: Dictionary = item as Dictionary
			result.append(item_data)

	return result


func _count_available_fish(species_id: String) -> int:
	# 捕獲済みではない魚だけを「フィールドにいる魚」として数えます。
	var count: int = 0

	for fish: Dictionary in fish_instances:
		if String(fish.get("species_id", "")) != species_id:
			continue

		if bool(fish.get("is_caught", false)):
			continue

		count += 1

	return count


func _get_random_spawn_position(spawn_rule: Dictionary) -> Vector2:
	# spawn_centerを中心に、spawn_radius内のランダムな位置を作ります。
	# sqrt(randf())を使うと、円の中心に偏りにくい分布になります。
	var spawn_center: Vector2 = _read_position(spawn_rule.get("spawn_center", Vector2.ZERO))
	var spawn_radius: float = float(spawn_rule.get("spawn_radius", 0.0))
	var angle: float = randf_range(0.0, TAU)
	var distance: float = sqrt(randf()) * spawn_radius

	return spawn_center + Vector2.RIGHT.rotated(angle) * distance


func _read_position(value: Variant) -> Vector2:
	# JSON由来のDictionaryと、Godot内のVector2の両方をVector2として扱います。
	if value is Vector2:
		return value

	if value is Dictionary:
		var position_data: Dictionary = value as Dictionary
		return Vector2(
			float(position_data.get("x", 0.0)),
			float(position_data.get("y", 0.0))
		)

	return Vector2.ZERO
