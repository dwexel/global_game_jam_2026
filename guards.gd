extends CharacterBody2D

const SPEED = 30

var direction = Vector2i(0,0)

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_up: RayCast2D = $RayCastUp
@onready var ray_cast_down: RayCast2D = $RayCastDown
@onready var player_check: RayCast2D = $player_check
@onready var player_character: CharacterBody2D = $"../PlayerCharacter"

func _process(delta):
	
	
	pick_new_direction()
	#check_collision()
	check_door()
	
	position.x += direction.x * SPEED * delta
	position.y += direction.y * SPEED * delta

func pick_new_direction():
	var collider = player_check.get_collider()
	if collider == player_character:
		var player_location_x = player_character.global_position.x
		var player_location_y = player_character.global_position.y
		if position.x < player_location_x:
			direction.x = 1
		elif position.x > player_location_x:
			direction.x = -1
		if position.y < player_location_y:
			direction.y = 1
		elif position.y > player_location_y:
			direction.y = -1
		#print("found player ", player_location_x)
		#print("found player ", player_location_y)

func check_collision():
	if ray_cast_right.is_colliding():
		direction.x = -1
		#animated_sprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction.x = 1
		#animated_sprite.flip_h = false
	if ray_cast_up.is_colliding():
		direction.y = 1
	if ray_cast_down.is_colliding():
		direction.y = -1

func check_door():
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
