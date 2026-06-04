class_name FishInstance
extends RefCounted

# FishInstanceは「魚種」ではなく、フィールド内にいる1匹の魚を表します。
# RefCountedなのでシーンツリーに置かず、データ用オブジェクトとして使えます。
var id: String = ""
var species_id: String = ""
var species_name: String = ""

var size: float = 0.0
var weight: float = 0.0

var age_days: float = 0.0
var growth_rate: float = 0.0

var stamina: float = 100.0
var power: float = 10.0

var position: Vector2 = Vector2.ZERO

var is_caught: bool = false

var spawn_time: float = 0.0
var last_update_time: float = 0.0


## Dictionaryの値で魚個体の状態を初期化します。
## 引数: data 魚個体の初期データ
## 戻り値: なし
func setup(data: Dictionary) -> void:
	id = String(data.get("id", ""))
	species_id = String(data.get("species_id", ""))
	species_name = String(data.get("species_name", ""))

	size = float(data.get("size", 0.0))
	weight = float(data.get("weight", 0.0))

	age_days = float(data.get("age_days", 0.0))
	growth_rate = float(data.get("growth_rate", 0.0))

	stamina = float(data.get("stamina", 100.0))
	power = float(data.get("power", 10.0))

	position = _read_position(data.get("position", Vector2.ZERO))

	is_caught = bool(data.get("is_caught", false))

	spawn_time = float(data.get("spawn_time", 0.0))
	last_update_time = float(data.get("last_update_time", spawn_time))


## 経過日数に応じて魚個体を成長させます。
## 引数: days 経過日数
## 戻り値: なし
func grow(days: float) -> void:
	if days <= 0.0 or is_caught:
		return

	age_days += days
	size = snapped(size + growth_rate * days, 0.1)
	weight = snapped(weight + growth_rate * power * days * 0.01, 0.1)
	last_update_time += days * 86400.0


## 魚個体の状態をDictionaryへ変換します。
## 引数: なし
## 戻り値: 魚個体データのDictionary
func to_dict() -> Dictionary:
	return {
		"id": id,
		"species_id": species_id,
		"species_name": species_name,
		"name": species_name,
		"size": size,
		"weight": weight,
		"age_days": age_days,
		"growth_rate": growth_rate,
		"stamina": stamina,
		"power": power,
		"position": {
			"x": position.x,
			"y": position.y
		},
		"is_caught": is_caught,
		"spawn_time": spawn_time,
		"last_update_time": last_update_time
	}


## Dictionaryから魚個体の状態を復元します。
## 引数: data 復元する魚個体データ
## 戻り値: なし
func from_dict(data: Dictionary) -> void:
	setup(data)


func _read_position(value: Variant) -> Vector2:
	# JSONではVector2を直接保存できないため、{"x": 0, "y": 0}形式も受け取れるようにします。
	if value is Vector2:
		return value

	if value is Dictionary:
		var position_data: Dictionary = value as Dictionary
		return Vector2(
			float(position_data.get("x", 0.0)),
			float(position_data.get("y", 0.0))
		)

	return Vector2.ZERO
