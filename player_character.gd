extends CharacterBody2D
#extends KinematicBody2D

# Movement speed in pixels per second.
@export var speed := 50



func _physics_process(delta):
	#const SPEED = 600.0
	
	var direction = Input.get_vector("left", "right", "up", "down")
	
	#var direction = Vector2.ZERO
	#if Input.is_action_pressed("left"):
		#direction.x = -1
	#elif Input.is_action_pressed("right"):
		#direction.x = 1
	#elif Input.is_action_pressed("up"):
		#direction.y = -1
	#elif Input.is_action_pressed("down"):
		#direction.y = 1
	#
	
	velocity = direction * speed

	move_and_slide()
	check_slide_collisions()




func check_slide_collisions():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is Level:
			var _global_position = collision.get_position()
			var _normal = collision.get_normal()
			
			var _tile_position = collider.to_local(_global_position - _normal)
			
			
			var map_coords = collider.local_to_map(_tile_position)
			var _tile_data = collider.get_cell_tile_data(map_coords)
			var atlas_coords = collider.get_cell_atlas_coords(map_coords)
			
			if collider.is_door(atlas_coords):
				collider.open_door(map_coords)
				
			
				


func _on_pickup(body: Node2D):
	print("don't use")
