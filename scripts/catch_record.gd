extends Node

var records: Dictionary = {}
var history: Array[Dictionary] = []

func add_catch(fish: Dictionary) -> void:
	history.append(fish)

	var fish_id: String = fish["id"]

	if not records.has(fish_id):
		records[fish_id] = {
			"name": fish["name"],
			"count": 0,
			"max_size": 0.0,
			"max_weight": 0.0
		}

	records[fish_id]["count"] += 1
	records[fish_id]["max_size"] = max(records[fish_id]["max_size"], fish["size"])
	records[fish_id]["max_weight"] = max(records[fish_id]["max_weight"], fish["weight"])

func get_records() -> Dictionary:
	return records

func get_history() -> Array[Dictionary]:
	return history
