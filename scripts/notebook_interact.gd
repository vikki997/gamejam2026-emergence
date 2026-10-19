extends Area2D

@onready var notebook_popup = $"../NotebookPopup"
var blink_tween: Tween

func _ready():
	# ★ 修正：使用 popup_hide 信号，而不是 hide 函数
	notebook_popup.popup_hide.connect(_on_popup_closed)
	notebook_popup.hide() # 确保一开始是隐藏的

# 用于在开场剧情结束后，由孩子房间的主脚本调用
func start_blink():
	if blink_tween: blink_tween.kill()
	blink_tween = create_tween().set_loops()
	blink_tween.tween_property(self, "modulate", Color(1.5, 1.5, 1.5), 0.5)
	blink_tween.tween_property(self, "modulate", Color(1, 1, 1), 0.5)

# 停止闪烁
func stop_blink():
	if blink_tween:
		blink_tween.kill()
	modulate = Color(1, 1, 1)

# 鼠标点击交互
func _on_input_event(viewport, event, shape_idx):
	# 剧情锁。如果正在播剧情，点笔记本没反应
	if GameManager.is_cutscene: return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# 1. 点开后，先停止闪烁
		stop_blink()
		
		# 2. 显示弹窗
		notebook_popup.popup_centered()
		
		viewport.set_input_as_handled()

# ★ 关闭弹窗后自动触发
func _on_popup_closed():
	# 防止重复触发
	if GameManager.notebook_read:
		return
		
	# 记录状态，表示玩家看过了
	GameManager.notebook_read = true
	
	# 触发孩子房间的“天黑”逻辑
	if get_parent().has_method("start_night"):
		get_parent().start_night()
