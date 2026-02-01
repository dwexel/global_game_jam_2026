extends Node2D
class_name Waypoint

@export var player_character: Node2D

func _ready() -> void:
	print(get_path())
