extends Control

@onready var evidence: Control = $"."
@onready var label: Label = $PanelContainer/ScrollContainer/Label

func _ready() -> void:
	# loads the actual content on instancing
	var data = read_csv_file("res://assets/documents-library.csv")
	label.text = data[0][0]
	print("label.text ", label.text)
	print("data ", data[0][0])
	evidence.position = Vector2(0,0)
	evidence.size = Vector2(128, 128)

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
