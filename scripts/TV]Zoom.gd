extends Control

# 关闭信号，通知主场景恢复交互
signal closed

func _ready():
	# 连接右上角的图片关闭按钮（TextureButton 也有 pressed 信号）
	$CloseButton.pressed.connect(_on_close)
	# 连接右半边的透明点击区域
	$ClickArea.pressed.connect(_on_click_area)

func _on_click_area():
	# 加载 Hashi 谜题场景
	var puzzle_scene = load("res://scenes/zoom/HashiPuzzle.tscn")
	
	# 确保场景加载成功
	if puzzle_scene:
		var puzzle = puzzle_scene.instantiate()
		# 把谜题添加到当前场景的 ZoomLayer 中
		get_tree().current_scene.get_node("ZoomLayer").add_child(puzzle)
		
		# 隐藏当前的电视特写界面（不销毁，等谜题关掉还要回来）
		hide()
		
		# 监听谜题关闭的信号
		if puzzle.has_signal("closed"):
			puzzle.closed.connect(_on_puzzle_closed)

func _on_puzzle_closed():
	# 谜题关闭后，重新显示电视特写
	show()

func _on_close():
	# 点击右上角关闭，发出信号并销毁自己
	closed.emit()
	queue_free()
