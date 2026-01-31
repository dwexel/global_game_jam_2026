extends TileMapLayer
class_name Level

enum {GREEN, BLUE, RED, WHITE}

func is_door(atlas_coords: Vector2i):
	return atlas_coords == Vector2i(12, 5)
	

func open_door(map_coords: Vector2i):
	# using tile source 0 in the TileSet
	# swtiching to tile at atlas position 12, 3
	set_cell(map_coords, 0, Vector2i(12, 3))
	
	# wait 3 sec
	await get_tree().create_timer(3).timeout
	
	# back to the door tile
	set_cell(map_coords, 0, Vector2i(12, 5))


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
