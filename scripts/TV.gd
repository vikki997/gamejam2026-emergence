extends Area2D

@export var zoom_scene: PackedScene

func _ready():
	add_to_group("interactable")
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# 游戏一开始，根据状态更新画面
	_update_visual()

# 根据 GameManager 的状态切换关屏/开屏
func _update_visual():
	if GameManager.tv_solved:
		$Sprite_Off.visible = false
		$Sprite_On.visible = true
	else:
		$Sprite_Off.visible = true
		$Sprite_On.visible = false

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
	
	# 特写关闭后，再次检查状态（可能刚才解谜成功了）
	_update_visual()
	
	# ★ 核心新增：通知当前场景（客厅）刷新碎片4的状态！
	if get_tree().current_scene.has_method("update_fragment4"):
		get_tree().current_scene.update_fragment4()

func set_input_enabled(enabled: bool):
	input_pickable = enabled

func _on_mouse_entered():
	modulate = Color(1.15, 1.15, 1.15)

func _on_mouse_exited():
	modulate = Color(1, 1, 1)
