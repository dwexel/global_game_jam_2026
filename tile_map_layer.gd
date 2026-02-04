extends TileMapLayer
class_name Level

#enum {GREEN, BLUE, RED, WHITE}


var _astar = AStarGrid2D.new()
var _start_point := Vector2i()
var _end_point := Vector2i()
var _path := PackedVector2Array()

#const BASE_LINE_WIDTH: float = 3.0
const DRAW_COLOR = Color.WHITE * Color(1, 1, 1, 0.5)
const DEBUG_DRAW = false

# 3, 3; 4, 1; 0, 1
const DOOR_TILE = [Vector2i(3, 3), Vector2i(4, 1), Vector2i(0, 1)]


const TOP_LEFT_CELL = Vector2i(-23, -23)
const BOTTOM_RIGHT_CELL = Vector2i(22, 22)


func _ready() -> void:
	_astar.region = Rect2i(TOP_LEFT_CELL, BOTTOM_RIGHT_CELL-TOP_LEFT_CELL)
	_astar.cell_size = tile_set.tile_size
	
	_astar.offset = tile_set.tile_size * 0.5
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astar.update()
	
	# just use the tiles in this layer as 
	# solid cells for astar
	for pos in get_used_cells():
		if get_cell_atlas_coords(pos) in DOOR_TILE:
			# don't use this cell as solid
			pass
		else:
			_astar.set_point_solid(pos)



func _draw() -> void:
	if DEBUG_DRAW:
		for pos in get_used_cells():
			draw_circle(map_to_local(pos), 5, DRAW_COLOR)
		

#func is_point_walkable(local_position: Vector2) -> bool:
func is_point_walkable(map_position: Vector2i) -> bool:
	#var map_position: Vector2i = local_to_map(local_position)
	if _astar.is_in_boundsv(map_position):
		return not _astar.is_point_solid(map_position)
	return false


func set_point_walkable(map_position: Vector2i, solid):
	_astar.set_point_solid(map_position, solid)


func clear_path() -> void:
	if not _path.is_empty():
		_path.clear()

func find_path(local_start_point: Vector2i, local_end_point: Vector2i) -> PackedVector2Array:
	# use doors? as a param
	
	clear_path()

	_start_point = local_to_map(local_start_point)
	_end_point = local_to_map(local_end_point)
	_path = _astar.get_point_path(_start_point, _end_point, true)

	return _path.duplicate()



func find_random_path(local_start_point: Vector2i) -> PackedVector2Array:
	# choose a random path
	_start_point = local_to_map(local_start_point)
	
	for i in 10:
		# end point
		_end_point = Vector2i(
			randi_range(TOP_LEFT_CELL.x, BOTTOM_RIGHT_CELL.x),
			randi_range(TOP_LEFT_CELL.y, BOTTOM_RIGHT_CELL.y)
			)
		
		if is_point_walkable(_end_point):
			break
	
	for i in 10:
		_path = _astar.get_point_path(_start_point, _end_point)
		if _path != null:
			return _path.duplicate()
	
		#_end_point = map_pos
		

		#if is_point_walkable(map_pos):
			
			# no partial path
			#_path = _astar.get_point_path(_start_point, _end_point)
			
			#if _path != null:
				#return _path.duplicate()

			
	
	
	return []
			


 
		
	
	



func is_door(atlas_coords: Vector2i):
	return atlas_coords in DOOR_TILE
	

func open_door(map_coords: Vector2i):
	var audio = AudioStreamPlayer2D.new()
	audio.attenuation = 0.5
	audio.position = map_to_local(map_coords)
	add_child(audio)
	#audio.stream = preload("res://assets/whistle.wav")
	audio.stream = preload("res://assets/armor-light.wav")
	audio.play()
	
	
	var atlas_coords = get_cell_atlas_coords(map_coords)
	
	
	
	# using tile source 0 in the TileSet
	#set_cell(map_coords, 0, BLANK_TILE)
	erase_cell(map_coords)
	
	# wait 3 sec
	await get_tree().create_timer(3).timeout
	audio.stream = preload("res://assets/interface6.wav")
	audio.play()
	
	
	# back to the door tile
	set_cell(map_coords, 0, atlas_coords)


func do_pickup(map_coords: Vector2i):
	#set_cell(map_coords, 0, BLANK_TILE)
	erase_cell(map_coords)


func is_pickup(atlas_coords: Vector2i):
	return false


#func get_color(atlas_coords: Vector2i):
	#if atlas_coords.x == 0:
		#return GREEN
	#elif atlas_coords.x == 2:
		#return BLUE
	#elif atlas_coords.x == 3:
		#return RED
	#elif atlas_coords.x == 4:
		#return WHITE
