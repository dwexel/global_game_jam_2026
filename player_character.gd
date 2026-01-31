extends CharacterBody2D
#extends KinematicBody2D

# Movement speed in pixels per second.
@export var speed := 500

func _physics_process(delta):
	const SPEED = 600.0
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * SPEED

	move_and_slide()
