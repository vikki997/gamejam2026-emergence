extends Control

# 关闭信号，通知主场景恢复交互
signal closed

func _ready():
	# 连接右上角的图片关闭按钮
	$CloseButton.pressed.connect(_on_close)
	# 连接右半边的透明点击区域
	$ClickArea.pressed.connect(_on_click_area)
	
	# ★ 核心修复 1：强制让 SolvedImage 不拦截鼠标事件，防止它挡住按钮的点击
	if has_node("SolvedImage"):
		$SolvedImage.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
	# ★ 核心修复 2：强制把关闭按钮移到场景树的最底层（渲染的最顶层），确保永远不被遮挡
	move_child($CloseButton, -1)
	
	# 游戏一开始打开时，先根据状态更新一次画面
	_update_ui()

# 统一管理 UI 显示状态
func _update_ui():
	if GameManager.tv_solved:
		# 如果已经解谜，显示接通图，关闭透明点击区
		if has_node("SolvedImage"):
			$SolvedImage.visible = true
		$ClickArea.disabled = true
		$ClickArea.visible = false
	else:
		# 如果未解谜，隐藏接通图，开启透明点击区
		if has_node("SolvedImage"):
			$SolvedImage.visible = false
		$ClickArea.disabled = false
		$ClickArea.visible = true

func _on_click_area():
	# 如果已经解谜了，点击右半边也不再生效
	if GameManager.tv_solved:
		return
		
	# 加载 Hashi 谜题场景
	var puzzle_scene = load("res://scenes/zoom/HashiPuzzle.tscn")
	
	if puzzle_scene:
		var puzzle = puzzle_scene.instantiate()
		get_tree().current_scene.get_node("ZoomLayer").add_child(puzzle)
		
		# 隐藏当前的电视特写界面
		hide()
		
		# 监听谜题关闭的信号
		if puzzle.has_signal("closed"):
			puzzle.closed.connect(_on_puzzle_closed)
			
		# 监听谜题通关成功的信号
		if puzzle.has_signal("puzzle_solved"):
			puzzle.puzzle_solved.connect(_on_puzzle_success)

# 收到通关信号，记录状态
func _on_puzzle_success():
	GameManager.tv_solved = true
	print("收到小游戏通关信号，电视已切换为开屏状态")
	# 通关瞬间，更新特写界面的状态，变成接通图
	_update_ui()

func _on_puzzle_closed():
	# 谜题关闭后，重新显示电视特写
	show()
	# 关闭小游戏回到特写时，再次确保 UI 状态正确（如果刚通关，会变成接通图）
	_update_ui()

func _on_close():
	# 点击右上角关闭，发出信号并销毁自己
	closed.emit()
	queue_free()
