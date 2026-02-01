extends Control

@onready var evidence: Control = $"."
@onready var label: Label = $PanelContainer/ScrollContainer/Label

var documents_all = []

func _ready() -> void:
	# loads the actual content on instancing
	var files = list_files_in_directory("res://assets/Txt Files for Ryan/")
	var full_text = ""
	
	for textx in files.pick_random():
		for texty in textx:
			full_text += texty
		
	label.text = full_text
	evidence.position = Vector2(0,0)
	evidence.size = Vector2(128, 128)

func list_files_in_directory(path: String) -> Array:
	# Use the static method for convenience
	var files: PackedStringArray = DirAccess.get_files_at(path)
	
	if files.is_empty():
		print("No files found or an error occurred when trying to access the path.")
		return []

	print("Files in directory: " + path)
	for file_name in files:
		# Construct the full path if needed, e.g., for loading the resource
		var full_path = path.path_join(file_name) 
		print(full_path)
		var current_file = read_csv_file(full_path)
		documents_all.append(current_file)
		# To load a resource dynamically:
		# var loaded_resource = ResourceLoader.load(full_path)
	print("documents ", documents_all)
	return documents_all

func read_csv_file(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("Error opening file: ", FileAccess.get_open_error())
		return []

	var data = []
	while not file.eof_reached():
		var line_array = file.get_csv_line()
		var is_empty_line = line_array.size() > 0 and line_array[0] != ""
		if is_empty_line: # Basic check for empty lines
			data.append(line_array)
	
	file.close()
	
	return data

func _input(event: InputEvent) -> void:
	const FULL_SPEED = 1.0
	var is_wasd_input = event.is_action_pressed("down") || event.is_action_pressed("left") || event.is_action_pressed("up") || event.is_action_pressed("right")
	if is_wasd_input:
		Engine.set_time_scale(FULL_SPEED)
		evidence.queue_free()
