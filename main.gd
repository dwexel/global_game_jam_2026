extends Node2D

@onready var PAPER_EVIDENCE = preload("uid://bppcibjqhnm3u")
@onready var pickup: Node2D = $Pickup
@onready var main: Node2D = $"."
const GUARDS = preload("uid://cgvxnltyi2dkn")

func _on_pickup_evidence_picked_up() -> void:
	# pause the game
	var evidence = PAPER_EVIDENCE.instantiate()
	add_child(evidence)
	# doing slow time because pause removes input handling except for the pause thing
	const STOP_TIME = 0.00
	Engine.set_time_scale(STOP_TIME)
