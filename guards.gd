extends CharacterBody2D

const SPEED = 10
const GUARD_SIGHT_RANGE = 32

@onready var guards: CharacterBody2D = $"."
@onready var player_check: RayCast2D = $player_check
@onready var line_2d: Line2D = $player_check/Line2D
@onready var player_character: CharacterBody2D = $"../PlayerCharacter"
@onready var light_cone: Node2D = $LightPivot
@onready var level: Level = $"/root/Main/Level"


# what is the current pathfinding path?
var path
var path_i = 0
var nearest_tile: Vector2i


# what is the guard state
enum GuardState {PACING, CHASING, NONE}
var state: GuardState = GuardState.PACING

# waypoints for creating a path
@export var waypoints: Array[Waypoint]
var current_waypoint

# snapped direction for facing
var facing


func _ready() -> void:
	if len(waypoints) > 0:
		reset_path_to_waypoint(waypoints[0])
		current_waypoint = waypoints[0]
		state = GuardState.PACING
	else:
		state = GuardState.NONE


func _physics_process(delta: float) -> void:
	if state == GuardState.PACING:
		var direction: Vector2 = process_path_follow()
		velocity = direction * SPEED
		light_cone.look_at(get_current_waypoint_pos())
		
		if check_sight():
			pass
		
	else:
		
		velocity = Vector2.ZERO
	
	move_and_slide()
	#var direction = pick_new_direction()
	#velocity = direction * SPEED
	#move_and_slide()


func process_path_follow():
	if state != GuardState.PACING:
		return
	
	var dest: Vector2 = nearest_tile
	var to_nearest = (dest - position)
	
	if to_nearest.length() < 2:
		path_i += 1
		
		if path_i == len(path):
			reset_path_to_waypoint(null)
			current_waypoint = Waypoint.new()
			current_waypoint.position = player_character.position
			
		nearest_tile = path[path_i]
		dest = nearest_tile
		to_nearest = (dest - position)
	
	return to_nearest.normalized()


func get_current_waypoint_pos():
	return current_waypoint.position


func reset_path_to_waypoint(waypoint: Waypoint):
	
	if waypoint == null:
		path = level.find_path(
			global_position - level.global_position,
			player_character.global_position - level.global_position
		)
		path_i = 0
		nearest_tile = path[path_i]
		return
	
	path = level.find_path(
		global_position - level.global_position, 
		waypoint.global_position - level.global_position
	)
	path_i = 0
	nearest_tile = path[path_i]
	

func _unhandled_input(event: InputEvent) -> void:
	if event.as_text() == "B" and event.is_pressed():
		if state == GuardState.PACING:
			path_i += 1
			nearest_tile = path[path_i]


func check_sight():
	if state != GuardState.PACING:
		return
	
	var pc_pos = -(guards.position - current_waypoint.position)
	var pc_direction = pc_pos.limit_length(GUARD_SIGHT_RANGE)
	player_check.target_position = pc_pos
	line_2d.points = [Vector2.ZERO, pc_direction]
	
	if pc_pos.length() < GUARD_SIGHT_RANGE:
		pass
	else:
		return

	if player_check.is_colliding():
		if player_check.get_collider() == player_character:
			print("found player")
			return
	
	

#
#func pick_new_direction():
	## track the player
	#var pc_pos = -1 * (guards.position - player_character.position)
	#var pc_direction = pc_pos.limit_length(GUARD_SIGHT_RANGE)
	#player_check.target_position = pc_pos
	#line_2d.points = [Vector2(0,0), pc_direction]
	#
	## point light at the player
	#light_cone.look_at(player_character.global_position)
	#
	#if player_check.is_colliding():
		#if player_check.get_collider() != player_character:
			#return Vector2(0, 0)
	#
	#
	#if pc_pos.length() < GUARD_SIGHT_RANGE:
		##print("player found")
		#return pc_pos
	#else:
		##print("no player found")
		#return Vector2(0,0)


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
