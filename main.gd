extends Node2D

@onready var PAPER_EVIDENCE = preload("uid://bppcibjqhnm3u")
@onready var pickup: Node2D = $Pickup

func _on_pickup_evidence_picked_up() -> void:
	# pause the game
	var evidence = PAPER_EVIDENCE.instantiate()
	add_child(evidence)
	
	#evidence.position = pickup.position
