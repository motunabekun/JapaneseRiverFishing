extends Node

# Autoloadとして使う、ゲーム全体で共有する状態置き場です。
# どのシーンからでも GameState.is_fishing のように参照できます。
var is_fishing: bool = false
var money: int = 0
var fish_biting: bool = false


## 釣り中フラグを有効にします。
## 引数: なし
## 戻り値: なし
func start_fishing() -> void:
	is_fishing = true


## 釣り中フラグを無効にします。
## 引数: なし
## 戻り値: なし
func end_fishing() -> void:
	is_fishing = false


## 所持金を増やします。
## 引数: amount 加算する金額
## 戻り値: なし
func add_money(amount: int) -> void:
	money += amount


## 魚がアタリ中であることを記録します。
## 引数: なし
## 戻り値: なし
func start_bite() -> void:
	fish_biting = true


## 魚のアタリ状態を解除します。
## 引数: なし
## 戻り値: なし
func end_bite() -> void:
	fish_biting = false
