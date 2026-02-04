extends Node2D
class_name Waypoint

# time to wait after reaching this waypoint
@export var wait: float = 0.0

func _ready() -> void:
	# this node is probably placed on the corner of a tile in the editor
	# move it to the center
	# could turn this off later if need be
	#position += Vector2(4, 4)
	pass
	
