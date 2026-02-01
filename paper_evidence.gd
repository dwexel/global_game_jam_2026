extends Control

@onready var evidence: Control = $"."
@onready var label: Label = $PanelContainer/ScrollContainer/Label
#@export var text_content: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#label.text = text_content
	var data = read_csv_file("res://assets/documents-library.csv")
	label.text = data[0][0]
	print("label.text ", label.text)
	print("data ", data[0][0])
	evidence.position = Vector2(0,0)
	evidence.size = Vector2(128, 128)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func read_csv_file(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("Error opening file: ", FileAccess.get_open_error())
		return []

	var data = []
	while not file.eof_reached():
		# get_csv_line() returns a PackedStringArray of the values in the current line
		var line_array = file.get_csv_line()
		if line_array.size() > 0 and line_array[0] != "": # Basic check for empty lines
			data.append(line_array)
		
	file.close()
	
	return data
