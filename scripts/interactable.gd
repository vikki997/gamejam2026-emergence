extends Area2D

@export var zoom_scene: PackedScene

func _ready():
	add_to_group("interactable")
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if zoom_scene:
				open_zoom()
			viewport.set_input_as_handled()

func open_zoom():
	get_tree().call_group("interactable", "set_input_enabled", false)
	var zoom = zoom_scene.instantiate()
	get_tree().current_scene.get_node("ZoomLayer").add_child(zoom)
	if zoom.has_signal("closed"):
		zoom.closed.connect(_on_zoom_closed)

func _on_zoom_closed():
	get_tree().call_group("interactable", "set_input_enabled", true)
	# 衣架专属：解谜成功后，主场景衣架换图
	if name == "CoatRack" and GameManager.coatrack_solved:
		$Sprite2D.texture = preload("res://art/furniture/coat_rack_solved.png")

func set_input_enabled(enabled: bool):
	input_pickable = enabled

func _on_mouse_entered():
	modulate = Color(1.15, 1.15, 1.15)

func _on_mouse_exited():
	modulate = Color(1, 1, 1)
