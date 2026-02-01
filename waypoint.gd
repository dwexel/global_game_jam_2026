extends Node2D
class_name Waypoint

func _ready() -> void:
	# this node is probably placed on the corner of a tile in the editor
	# move it to the center
	# could turn this off later if need be
	position += Vector2(4, 4)
	
