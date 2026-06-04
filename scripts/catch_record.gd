extends Node

# recordsは魚種ごとの累計記録、historyはまだ売却していない釣果の一覧です。
var records: Dictionary = {}
var history: Array[Dictionary] = []


## 釣果を未売却履歴と魚種別の累計記録へ追加します。
## 引数: fish 釣れた魚のデータ
## 戻り値: なし
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

	# 同じ魚種を釣るたびに、匹数と最大記録だけを更新します。
	records[fish_id]["count"] += 1
	records[fish_id]["max_size"] = max(records[fish_id]["max_size"], fish["size"])
	records[fish_id]["max_weight"] = max(records[fish_id]["max_weight"], fish["weight"])


## 魚種別の累計記録を返します。
## 引数: なし
## 戻り値: 魚種IDをキーにした記録Dictionary
func get_records() -> Dictionary:
	return records


## 未売却の釣果履歴を返します。
## 引数: なし
## 戻り値: 釣果Dictionaryの配列
func get_history() -> Array[Dictionary]:
	return history
