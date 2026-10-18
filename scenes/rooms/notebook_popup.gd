extends PopupPanel

@onready var Btn_Close = $NotebookUI/Btn_Close

func _ready():
	print("找到按钮：", Btn_Close)
	Btn_Close.pressed.connect(_click_close)
	popup_hide.connect(on_close_popup)

func _click_close():
	print("叉号被点击！")
	hide()

func on_close_popup():
	# get_tree().paused = false 删掉这一行，不再需要恢复暂停
	pass
