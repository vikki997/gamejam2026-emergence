extends CanvasLayer

signal dialogue_finished

# ★ 核心：加上 @export 后，这些变量就会出现在右侧的“检查器”里，让你手动拖拽
@export var mask_node: Control
@export var box_node: Control
@export var name_label: Label
@export var text_label: Label

var lines = []
var current_idx = 0

func _ready():
	hide()
	# 如果拖入了遮罩，就给它绑定点击翻页事件
	if mask_node:
		mask_node.gui_input.connect(_on_mask_clicked)

func start_dialogue(new_lines: Array):
	lines = new_lines
	current_idx = 0
	show()
	if mask_node: mask_node.show()
	if box_node: box_node.show()
	show_next()

func show_next():
	if current_idx < lines.size():
		name_label.text = lines[current_idx]["name"]
		text_label.text = lines[current_idx]["text"]
	else:
		hide()
		dialogue_finished.emit()

func _on_mask_clicked(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		current_idx += 1
		show_next()
func play_intro():
	GameManager.is_cutscene = true
	print("★ 1. 准备开始剧情！")
	
	var lines = [
		{"name": "小熊", "text": "你终于醒了..."},
		{"name": "玩家", "text": "我不小心睡过头了..."}
	]
	
	if Engine.has_singleton("DialogueUI") or has_node("/root/DialogueUI"):
		print("★ 2. 找到了 DialogueUI，开始播报！")
		DialogueUI.start_dialogue(lines)
		await DialogueUI.dialogue_finished
		print("★ 3. 对话播完了！")
	else:
		print("❌ 致命错误：没找到 DialogueUI 单例！")
		await get_tree().create_timer(2.0).timeout
	
	GameManager.is_cutscene = false
	if has_node("Notebook"):
		$Notebook.start_blink()
