@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	#var t: TileSet = ResourceLoader.load("res://assets/tile_set.tres")
	
	#print(t.get_source_count())
	#pass
	
	var reference_frames: SpriteFrames = ResourceLoader.load("res://assets/player_sprite_frames_blue.tres")
	var updated_frames: SpriteFrames = SpriteFrames.new()
	
	
	var texture = ResourceLoader.load("res://assets/playerGreen.png")

	for animation in reference_frames.get_animation_names():
		if animation != "default":
			updated_frames.add_animation(animation)
			updated_frames.set_animation_speed(animation, reference_frames.get_animation_speed(animation))
			updated_frames.set_animation_loop(animation, reference_frames.get_animation_loop(animation))

			for i in reference_frames.get_frame_count(animation):
				var updated_texture: AtlasTexture = reference_frames.get_frame_texture(animation, i).duplicate()
				updated_texture.atlas = texture
				updated_frames.add_frame(animation, updated_texture)

	updated_frames.remove_animation("default")

	print("here")
	ResourceSaver.save(updated_frames, "res://assets/test.tres")
	
