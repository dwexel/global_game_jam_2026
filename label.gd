extends Label
@onready var label: Label = $"."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = "hello world"
	print(label.text)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
