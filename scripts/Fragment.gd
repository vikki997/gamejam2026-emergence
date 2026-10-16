extends Area2D

# ★ 每块碎片用不同的 id，方便物品栏区分
# 在检查器里设置，比如 "fragment1"、"fragment2"、"fragment3"
@export var item_id: String = "fragment3"

func _ready():
	add_to_group("interactable")
	# 如果已经收集过，直接隐藏
	if GameManager.has_item(item_id):
		queue_free()
		return
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			collect()
			viewport.set_input_as_handled()

func collect():
	GameManager.add_item(item_id)
	print("获得碎片：", item_id)
	queue_free()  # 从场景中删除自己

func _on_mouse_entered():
	modulate = Color(1.2, 1.2, 1.2)

func _on_mouse_exited():
	modulate = Color(1, 1, 1)
