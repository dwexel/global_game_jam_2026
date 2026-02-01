extends CharacterBody2D
class_name Guard

const SPEED = 10
const GUARD_SIGHT_RANGE = 42

@onready var guards: CharacterBody2D = $"."
@onready var player_check: RayCast2D = $player_check
@onready var line_2d: Line2D = $player_check/Line2D
@onready var player_character: CharacterBody2D = $"../PlayerCharacter"
@onready var light_cone: Node2D = $LightPivot
@onready var light_cone_actual = $LightPivot/PointLight2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var level: Level = $"/root/Main/Level"

#@export_enum("g1", "g2", "g3", "g4") var guard_type: String

var _position_last_frame := Vector2()
var _cardinal_direction = 0

var current_path
var current_path_i = 0

@export var waypoints: Array[Waypoint]
var waypoints_i = 0

# for detecting the player
var player_time = 0.0

# what mask color are we looking for
# player should never have "none"
var looking_for_mask = "none"

# what is the current time to detect the player?
var player_timeout = 2


var chase_mode = false



func _ready() -> void:
	#looking_for_mask = "green"
	looking_for_mask = player_character.masks[randi() % len(player_character.masks)]
	set_cone_color(looking_for_mask)

func set_cone_color(mask):
	light_cone.show()
	
	if mask == "none":
		light_cone.hide()
	elif mask == "white":
		light_cone.get_node("PointLight2D").color = Color.WHITE
	elif mask == "yellow":
		light_cone.get_node("PointLight2D").color = Color("ffa300")
	elif mask == "green":
		light_cone.get_node("PointLight2D").color = Color("00b543")
	elif mask == "red":
		light_cone.get_node("PointLight2D").color = Color("ff004d")
	elif mask == "blue":
		light_cone.get_node("PointLight2D").color = Color("065ab5")



func _physics_process(_delta: float) -> void:
	var direction = pick_new_direction()
	var facing_direction = get_facing_direction()
	play_walking_animation(facing_direction)
	
	var guard_destination = get_guard_destination()
	light_cone.look_at(guard_destination)
	
	var player = check_for_player(guard_destination)
	if player:
		if player_character.get_mask_color() == looking_for_mask:
			player_time += _delta
			print("here")
	
	light_cone_actual.energy = lerpf(1, 4.5, (player_time/2))
	light_cone_actual.energy = clampf(light_cone_actual.energy, 1, 4.5)
	
	if player_time > 2:
		print("game over")
	
	
	velocity = direction * SPEED
	move_and_slide()


func _draw() -> void:
	select_guard()


func select_guard():
	var animation_names := animated_sprite_2d.sprite_frames.get_animation_names()
	var random_ani_name = animation_names[randi() % animation_names.size()]
	print(random_ani_name)
	animated_sprite_2d.play(random_ani_name)


# deal with the path
func pick_new_direction() -> Vector2:
	if current_path == null:
		#print("selecting new path...", self)
		
		var _dest = select_next_waypoint()
		if _dest == null:
			return Vector2.ZERO
		
		# takes pixel coordinates local to the level node
		current_path = level.find_path(position, _dest.position)
		current_path_i = 0
		
		assert(current_path != null)
		assert(len(current_path) > 0)
		

	
func _draw() -> void:
	select_guard()
	
func select_guard():
	var animation_names := animated_sprite_2d.sprite_frames.get_animation_names()
	var random_ani_name = animation_names[randi() % animation_names.size()]
	print(random_ani_name)
	animated_sprite_2d.play(random_ani_name)

# deal with the path
func pick_new_direction() -> Vector2:
	if current_path == null:
		#print("selecting new path...", self)
		
		var _dest = select_next_waypoint()
		if _dest == null:
			return Vector2.ZERO
		
		# takes pixel coordinates local to the level node
		current_path = level.find_path(position, _dest.position)
		current_path_i = 0
		
		assert(current_path != null)
		assert(len(current_path) > 0)
		

	
	var _direction: Vector2 = (current_path[current_path_i] - position)
	
	if _direction.length() < 2:
		current_path_i += 1
	
	if current_path_i == len(current_path):
		current_path = null
		current_path_i = null
		return Vector2.ZERO
	
	_direction = (current_path[current_path_i] - position)
	
	return _direction.normalized()
	


func select_next_waypoint() -> Waypoint:
	if len(waypoints) == 0:
		return null;
	
	waypoints_i = (waypoints_i + 1) % len(waypoints)
	return (waypoints[waypoints_i])


func get_guard_destination() -> Vector2:
	if len(waypoints) == 0:
		return Vector2(0, 0)
	
	return waypoints[waypoints_i].global_position
	

func check_for_player(by_pointing_at: Vector2):
	var pc_pos = -1 * (guards.position - by_pointing_at)
	player_check.target_position = pc_pos
	
	# visual only aspect
	var pc_direction = pc_pos.limit_length(GUARD_SIGHT_RANGE)
	
	line_2d.points = [Vector2(0,0), pc_direction]
	
	#/print(by_pointing_at.angle_to(pc_pos))
	var _a = looking_dir.angle_to(pc_pos)
	#
	#if abs(_a) > PI/4:
		#line_2d.default_color.g = 0.0
	#else:
		#line_2d.default_color.g = 1.0
	
	var player_pos = player_character.position - guards.position
	
	if player_check.is_colliding():
		if player_check.get_collider() == player_character:
			if player_pos.length() <= GUARD_SIGHT_RANGE:
				return true
	
	if player_check.is_colliding():
		if player_check.get_collider() == player_character:
			if player_pos.length() <= GUARD_SIGHT_RANGE:
				if abs(_a) < PI/4:
					return true
	
	return false

#func check_door():
	#for i in get_slide_collision_count():
		#var collision = get_slide_collision(i)
		#var collider = collision.get_collider()
		#
		#if collider is Guard:
			#print("collided with guard here")
		#
		#if collider is Level:
			#var _global_position = collision.get_position()
			#var _normal = collision.get_normal()
			#
			#var _tile_position = collider.to_local(_global_position - _normal)
			#
			#var map_coords = collider.local_to_map(_tile_position)
			#var _tile_data = collider.get_cell_tile_data(map_coords)
			#var atlas_coords = collider.get_cell_atlas_coords(map_coords)
			#
			#if collider.is_door(atlas_coords):
				#collider.open_door(map_coords)



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

#
#func _on_player_character_player_sound(at: Vector2) -> void:
	#var at_distance = (position - at).length()
	#
	#if at_distance >= 60:
		#return
	#
	#var wait_time
	#
	#if at_distance < 60:
		#wait_time = 3
	#elif at_distance < 30:
		#wait_time = 0.5
#
	#await get_tree().create_timer(wait_time).timeout
	#
	#var _w = Waypoint.new()
	#_w.position = at
	#waypoints.insert(waypoints_i, _w)
	#
	#print(waypoints)
	#current_path = level.find_path(position, at)
	#current_path_i = 0
	#
	#assert(current_path != null)
	#assert(len(current_path) > 0)
