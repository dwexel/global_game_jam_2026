extends CharacterBody2D
class_name Guard

const SPEED = 10
const GUARD_SIGHT_RANGE = 42
const GUARD_CONE_ANGLE = deg_to_rad(45)

@onready var guards: CharacterBody2D = $"."
@onready var player_check: RayCast2D = $player_check
@onready var line_2d: Line2D = $player_check/Line2D
@onready var player_character: CharacterBody2D = $"/root/Main/PlayerCharacter"
@onready var light_cone: Node2D = $LightPivot
@onready var light_cone_actual = $LightPivot/PointLight2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var level: Level = $"/root/Main/Level"
@onready var overhead_animation: AnimatedSprite2D = $OverheadAnimation
@onready var wall_check : RayCast2D = $wall_check


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
@export var player_timeout = 2



var _deck: Array[Waypoint] = []

var nomove = false

@export var wait = 0.0



func _ready() -> void:
	looking_for_mask = player_character.masks[randi() % len(player_character.masks)]
	set_cone_color(looking_for_mask)
	
	if waypoints.is_empty():
		nomove = true
	
	if _deck.is_empty():
		_deck = waypoints.duplicate()
	



func _physics_process(_delta: float) -> void:
	var direction = pick_new_direction(_delta)
	var facing_direction = get_facing_direction()
	
	play_walking_animation(facing_direction)
	
	
	
	var guard_destination = get_guard_destination()
	
	#if wall_is_close(guard_destination):
		#guard_destination = position + direction * 10
	
	light_cone.look_at(guard_destination)
	
	
	if can_see_player(guard_destination) and player_character.get_mask_color() == looking_for_mask:
		
		
		player_time += _delta
		
		# what the fuck
		if overhead_animation.hidden:
			overhead_animation.show()
			overhead_animation.sprite_frames.set_animation_loop("question_mark", false)
			overhead_animation.play("question_mark")
	else:
		player_time -= _delta
		overhead_animation.hide()
		overhead_animation.stop()
	
	 
	player_time = clampf(player_time, 0, player_timeout)
	
	# set visual aspect
	light_cone_actual.energy = lerpf(1, 4.5, (player_time/player_timeout))
	
	
	velocity = direction * SPEED
	move_and_slide()
	check_slide_collisions()
	


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


func _draw() -> void:
	select_guard()


func select_guard():
	var animation_names := animated_sprite_2d.sprite_frames.get_animation_names()
	var random_ani_name = animation_names[randi() % animation_names.size()]
	animated_sprite_2d.play(random_ani_name)


# deal with the path
func pick_new_direction(delta) -> Vector2:
	
	# temp
	if nomove:
		return Vector2.ZERO
	
	if wait > 0:
		wait -= delta
		return Vector2.ZERO
	
	# reached end of waypoints list
	if _deck.is_empty():
		
		# good catch
		if waypoints.is_empty():
			nomove = true
			return Vector2.ZERO
			
		_deck = waypoints.duplicate()
	
	if current_path == null:
		var _dest = _deck[-1]
		current_path = level.find_path(position, _dest.position)
		current_path_i = 0
		assert(current_path != null, "pathing error?")
		assert(len(current_path) > 0, "pathing error?")
	
	
	var _direction: Vector2 = (current_path[current_path_i] - position)
	
	if _direction.length() < 2:
		current_path_i += 1
	
	if current_path_i == len(current_path):
		current_path = null
		current_path_i = null
		
		assert(len(_deck) > 0)
		wait += _deck[-1].wait
		
		_deck.pop_back()
		
		
		
		return Vector2.ZERO
	
	return _direction.normalized()
	



#func select_next_waypoint() -> Waypoint:
	#if len(waypoints) == 0:
		#return null;
	#
	#waypoints_i = (waypoints_i + 1) % len(waypoints)
	#return (waypoints[waypoints_i])


func get_guard_destination() -> Vector2:
	if len(_deck) == 0:
		return Vector2(0, 0)
	
	return _deck[-1].global_position
	

func wall_is_close(reference_position):
	var local_pos = reference_position - guards.position
	wall_check.target_position = reference_position
	
	if wall_check.is_colliding():
		var collision_point_global = wall_check.get_collision_point()
		
		# global and local are the same here
		if (collision_point_global - guards.global_position).length() < 8:
			return true
	
	return false


func can_see_player(by_pointing_at: Vector2):
	var pc_pos = (player_character.position - guards.position)
	var looking_dir = (by_pointing_at - guards.position)
	
	player_check.target_position = pc_pos
	var _a = looking_dir.angle_to(pc_pos)
	
	if player_check.is_colliding():
		if player_check.get_collider() == player_character:
			if pc_pos.length() <= GUARD_SIGHT_RANGE:
				if abs(_a) < PI/4:
					return true
	
	return false



func check_slide_collisions():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is Guard:
			# still emits collisions
			
			print("guard colliisions")
			
			var their_idx = collider.get_index()
			var our_idx = get_index()
			
			if our_idx > their_idx:
				
				# find the nxt path
				current_path = level.find_random_path(position)
				current_path_i = 0
				
				assert(len(current_path) > 0, "failed to find a path")
				
				var _w = Waypoint.new()
				_w.position = current_path[-1]
				_deck.push_back(_w)

			elif their_idx > our_idx:
				
				collision_layer = 0
				wait = 2.0
				
				
			else:
				assert(false, "error")
			
			print(wait)
		else:
			# no guard
			collision_layer = 0b1
		
		
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
				return

			for map_coord in collider.get_surrounding_cells(map_coords):
				var atlas_coord = collider.get_cell_atlas_coords(map_coord)
				if collider.is_door(atlas_coord):
					collider.open_door(map_coord)
					return


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



func _on_player_character_player_sound(at: Vector2) -> void:
	pass
	
	#var _w = Waypoint.new()
	#_w.position = at
	
	#
	#_deck.push_back(_w)
	#
	## temp, incase guard was created w/ no waypoiunts
	#nomove = false
	#
	#current_path = null
	#current_path_i = 0
	##current_path = level.find_path(position, at)
	##current_path_i = 0
	#
	##assert(current_path != null)
	##assert(len(current_path) > 0)
