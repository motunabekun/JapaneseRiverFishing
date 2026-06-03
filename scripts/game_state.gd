extends Node

var is_fishing: bool = false
var money: int = 0
var fish_biting: bool = false

func start_fishing() -> void:
	is_fishing = true

func end_fishing() -> void:
	is_fishing = false

func add_money(amount: int) -> void:
	money += amount

func start_bite() -> void:
	fish_biting = true

func end_bite() -> void:
	fish_biting = false
