extends Node2D

# note: hardcoded scene path
@onready var player = $"/root/Main/PlayerCharacter"
@onready var level: Level = $"/root/Main/Level"

@onready var area2d: Area2D = $Area2D

var timer: SceneTreeTimer

# timeout time
const TIMEOUT = 2.0



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player:
		timer = get_tree().create_timer(TIMEOUT)
		timer.timeout.connect(_on_timeout)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		timer.timeout.disconnect(_on_timeout)
		timer = null
	

func _on_timeout():
	print("DONE!")
	
	# our maps are superimposed
	var map_coords = level.local_to_map(position)
	
	level.do_pickup(map_coords)
	
	self.queue_free()
