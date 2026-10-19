extends Area2D

func _ready():
	# 连接鼠标输入和悬停效果
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("★ 1. 成功点到了箭头！") 
			
			input_pickable = false
			
			# ★ 核心修改：把 "living_room" 改成 "child_room" 去往孩子房间
			GameManager.go_to_room("child_room")
			
			print("★ 2. 已经呼叫跳转函数！") 
			
			viewport.set_input_as_handled()

func _on_mouse_entered():
	modulate = Color(1.2, 1.2, 1.2)

func _on_mouse_exited():
	modulate = Color(1, 1, 1)
