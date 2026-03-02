extends Node2D

# note: hardcoded scene path
@onready var player: Player = $"/root/Main/PlayerCharacter"
@onready var level: Level = $"/root/Main/Level"
@onready var area2d: Area2D = $Area2D

var timer: SceneTreeTimer
const TIMEOUT = 3.0

var mask: Player.Masks

func _ready() -> void:
	# no this doesn't work....
	mask = Player.Masks.values().pick_random()
	
	# well are we gonna do this?
	var map_coords = level.local_to_map(position)
	level.set_pickup_color(map_coords, mask)
	


func _process(delta: float) -> void:
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
	print("DONE!")
	
	# our maps are superimposed
	var map_coords = level.local_to_map(position)
	level.do_pickup(map_coords)
	
	
	player.set_mask_color(mask)
	
	
	
	#var guards = $"/root/Main/AllGuards"
	#
	#for g in guards.get_children():
		#var l = (g.position - position).length() 
#
		## what length?
		#if l < 50:
			#g.set_new_mask_from_event(mask)
		#
	
	self.queue_free()
