extends Node

var fish_list: Array = []

func _ready() -> void:
	load_fish_data()

func load_fish_data() -> void:
	var file: FileAccess = FileAccess.open("res://data/fish_data.json", FileAccess.READ)

	if file == null:
		push_error("魚データを読み込めませんでした")
		return

	var text: String = file.get_as_text()
	var json_data: Variant = JSON.parse_string(text)

	if json_data == null:
		push_error("魚データのJSON形式が間違っています")
		return

	fish_list = json_data as Array

func get_random_fish() -> Dictionary:
	if fish_list.is_empty():
		return {}

	var total_rate: int = 0

	for fish: Dictionary in fish_list:
		total_rate += int(fish["rate"])

	var random_value: int = randi_range(1, total_rate)
	var current: int = 0

	for fish: Dictionary in fish_list:
		current += int(fish["rate"])
		if random_value <= current:
			return generate_catch(fish)

	return generate_catch(fish_list[0])

func generate_catch(fish: Dictionary) -> Dictionary:
	var size: float = randf_range(float(fish["min_size"]), float(fish["max_size"]))
	var weight: float = size / float(fish["max_size"]) * float(fish["base_weight"])

	return {
		"id": fish["id"],
		"name": fish["name"],
		"size": snapped(size, 0.1),
		"weight": snapped(weight, 0.1),
		"sell_price": fish["sell_price"]
	}
