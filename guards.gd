extends CharacterBody2D

const SPEED = 60
const GUARD_SIGHT_RANGE = 32

@onready var guards: CharacterBody2D = $"."
@onready var player_check: RayCast2D = $player_check
@onready var line_2d: Line2D = $player_check/Line2D
@onready var player_character: CharacterBody2D = $"../PlayerCharacter"

func _physics_process(delta: float) -> void:
	var direction = pick_new_direction()
	velocity = direction * SPEED * delta
	move_and_slide()
	
func pick_new_direction():
	# track the player
	var pc_pos = -1 * (guards.position - player_character.position)
	var pc_direction = pc_pos.limit_length(GUARD_SIGHT_RANGE)
	player_check.target_position = pc_pos
	line_2d.points = [Vector2(0,0), pc_direction]
	
	if pc_pos.length() < GUARD_SIGHT_RANGE:
		print("player found")
		return pc_pos
	else:
		print("no player found")
		return Vector2(0,0)

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
