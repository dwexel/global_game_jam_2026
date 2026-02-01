extends CharacterBody2D
#extends KinematicBody2D

# Movement speed in pixels per second.
@export var speed := 50

# in order to compare w/ current input
var last_direction

# cause something happened to alert them
signal player_sound(at: Vector2)


func _physics_process(delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	
	if direction.x == 0:
		last_direction = direction
	elif direction.y == 0:
		last_direction = direction
	else:
		# hmm
		if last_direction.x == 0:
			direction.y = 0
		elif last_direction.y == 0:
			direction.x = 0
	
	velocity = direction * speed

	# the character collides for one frame.
	move_and_slide()
	check_slide_collisions()


func check_slide_collisions():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# rename
		if collider is Level:
			var _global_position = collision.get_position()
			var _normal = collision.get_normal()
			
			# because jank
			var _tile_position = collider.to_local(_global_position - _normal)
			
			# tile info
			var map_coords = collider.local_to_map(_tile_position)
			var _tile_data = collider.get_cell_tile_data(map_coords)
			var atlas_coords = collider.get_cell_atlas_coords(map_coords)
			
			if collider.is_door(atlas_coords):
				collider.open_door(map_coords)
				emit_door()
				return

			for map_coord in collider.get_surrounding_cells(map_coords):
				var atlas_coord = collider.get_cell_atlas_coords(map_coord)
				if collider.is_door(atlas_coord):
					collider.open_door(map_coord)
					emit_door()
					return
			
				
			

func emit_door():
	player_sound.emit(position)
	pass



@onready var bar = $BarEmpty
@onready var bar1 = $BarEmpty/BarFill
@onready var bar2 = $BarEmpty/BarFill2
@onready var bar3 = $BarEmpty/BarFill3
@onready var bar4 = $BarEmpty/BarFill4
@onready var bar5 = $BarEmpty/BarFill5
@onready var bar6 = $BarEmpty/BarFill6

func set_bar_progress(progress):
	#print(progress)
	
	bar.show()
	
	bar1.hide()
	bar2.hide()
	bar3.hide()
	bar4.hide()
	bar5.hide()
	bar6.hide()
	
	progress = progress * 6
	
	if progress == 6:
		pass
	if progress > 5:
		bar6.show()
	if progress > 4:
		bar5.show()
	if progress > 3:
		bar4.show()
	if progress > 2:
		bar3.show()
	if progress > 1:
		bar2.show()
	if progress > 0:
		bar1.show()
	
		
		

func set_bar_hidden():
	bar.hide()


func _on_pickup(body: Node2D):
	print("don't use")
