extends PopupPanel

@onready var Btn_Close = $NotebookUI/Btn_Close

func _ready():
	print("找到按钮: ", Btn_Close)
	Btn_Close.pressed.connect(_click_close)
	popup_hide.connect(_on_close_popup)

func _click_close():
	print("叉号被点击！")
	hide() # 隐藏弹窗会触发 popup_hide 信号，从而调用 _on_close_popup

# ★ 核心修改：弹窗彻底关闭后触发
func _on_close_popup():
	# 1. 记录玩家看过了日记本
	GameManager.notebook_read = true
	
	# 2. 通知父节点（也就是 Child's room 根节点）执行天黑逻辑
	var room = get_parent()
	if room.has_method("start_night"):
		room.start_night()
