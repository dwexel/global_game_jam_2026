extends TileMapLayer
class_name Level

enum {GREEN, BLUE, RED, WHITE}


var _astar = AStarGrid2D.new()
var _start_point := Vector2i()
var _end_point := Vector2i()
var _path := PackedVector2Array()

const BASE_LINE_WIDTH: float = 3.0
const DRAW_COLOR = Color.WHITE * Color(1, 1, 1, 0.5)



func _ready() -> void:
	_astar.region = Rect2i(0, 0, 100, 100)
	_astar.cell_size = tile_set.tile_size
	
	_astar.offset = tile_set.tile_size * 0.5
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astar.update()
	
	# just use the tiles in this layer as 
	# solid cells
	for pos in get_used_cells():
		_astar.set_point_solid(pos)



func is_point_walkable(local_position: Vector2) -> bool:
	var map_position: Vector2i = local_to_map(local_position)
	if _astar.is_in_boundsv(map_position):
		return not _astar.is_point_solid(map_position)
	return false


func clear_path() -> void:
	if not _path.is_empty():
		_path.clear()

func find_path(local_start_point: Vector2i, local_end_point: Vector2i) -> PackedVector2Array:
	clear_path()

	_start_point = local_to_map(local_start_point)
	_end_point = local_to_map(local_end_point)
	_path = _astar.get_point_path(_start_point, _end_point)

	return _path.duplicate()




func is_door(atlas_coords: Vector2i):
	return atlas_coords == Vector2i(3, 3)
	

func open_door(map_coords: Vector2i):
	# using tile source 0 in the TileSet
	# swtiching to tile at atlas position 12, 3
	set_cell(map_coords, 0, Vector2i(1, 2))
	
	# wait 3 sec
	await get_tree().create_timer(3).timeout
	
	# back to the door tile
	set_cell(map_coords, 0, Vector2i(3, 3))

func do_pickup(map_coords: Vector2i):
	set_cell(map_coords, 0, Vector2i(1, 2))
	

func is_pickup(atlas_coords: Vector2i):
	return false

func get_color(atlas_coords: Vector2i):
	if atlas_coords.x == 0:
		return GREEN
	elif atlas_coords.x == 2:
		return BLUE
	elif atlas_coords.x == 3:
		return RED
	elif atlas_coords.x == 4:
		return WHITE
