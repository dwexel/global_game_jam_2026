extends CharacterBody2D

const SPEED = 60
const GUARD_SIGHT_RANGE = 32

@onready var guards: CharacterBody2D = $"."
@onready var player_check: RayCast2D = $player_check
@onready var line_2d: Line2D = $player_check/Line2D
@onready var player_character: CharacterBody2D = $"../PlayerCharacter"
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var _position_last_frame := Vector2()
var _cardinal_direction = 0

func _physics_process(delta: float) -> void:
	var direction = pick_new_direction()
	var facing_direction = get_facing_direction()
	play_walking_animation(facing_direction)
	
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

func get_facing_direction():
	var motion = position - _position_last_frame

	if motion.length() > 0.0001:
		_cardinal_direction = int(4.0 * (motion.rotated(PI / 4.0).angle() + PI) / TAU)

	_position_last_frame = position
	
	return _cardinal_direction

enum IDLE {
	LEFT = 0,
	RIGHT = 3,
	DOWN = 6,
	UP = 9
}

enum WALK {
	LEFT = 1,
	RIGHT = 4,
	DOWN = 7,
	UP = 10,
}
	
func play_walking_animation(cardinal_direction: int):
	
	match cardinal_direction:
		0: # left
				animated_sprite_2d.set_frame_and_progress(IDLE.LEFT, 0)
		1: # up
				animated_sprite_2d.set_frame_and_progress(IDLE.UP, 0)
		2: # right
				animated_sprite_2d.set_frame_and_progress(IDLE.RIGHT, 0)
		3: # down
			animated_sprite_2d.set_frame_and_progress(IDLE.RIGHT, 0)
