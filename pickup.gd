extends Node2D

# note: hardcoded scene path
@onready var player = $"/root/Main/PlayerCharacter"
@onready var level: Level = $"/root/Main/Level"

const EVIDENCE_PAPER = preload("uid://kxn78y86fsnr")
const EVIDENCE_COMPUTER = preload("uid://bppcibjqhnm3u")

@onready var area2d: Area2D = $Area2D
signal evidence_picked_up;

var timer: SceneTreeTimer

# timeout time
const TIMEOUT = 3.0

func _process(_delta: float) -> void:
	if timer != null:
		player.set_bar_progress(timer.time_left / TIMEOUT)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player:
		timer = get_tree().create_timer(TIMEOUT)
		timer.timeout.connect(_on_timeout)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		player.set_bar_hidden()
		
		timer.timeout.disconnect(_on_timeout)
		timer = null

func _on_timeout():
	evidence_picked_up.emit()
	# our maps are superimposed
	var map_coords = level.local_to_map(position)
	level.do_pickup(map_coords)
	self.queue_free()
