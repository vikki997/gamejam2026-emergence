extends Control

signal closed

# 定义 4 个岛屿：pos 是屏幕坐标，target 是目标连线数
var islands = [
	{"pos": Vector2(400, 200), "target": 2, "current": 0},
	{"pos": Vector2(800, 200), "target": 3, "current": 0},
	{"pos": Vector2(400, 500), "target": 3, "current": 0},
	{"pos": Vector2(800, 500), "target": 2, "current": 0}
]

# 记录所有的桥: [起点索引, 终点索引, 桥的数量(1或2)]
var bridges = []

# 当前选中的岛屿索引（-1 表示未选中）
var selected_island = -1

func _ready():
	# 连接按钮
	$SubmitButton.pressed.connect(_on_submit)
	$CloseButton.pressed.connect(_on_close)
	# 触发一次绘制
	queue_redraw()

# ================= 绘制逻辑 =================
func _draw():
	# 1. 画所有的桥（线）
	for bridge in bridges:
		var idx1 = bridge[0]
		var idx2 = bridge[1]
		var count = bridge[2]
		
		var p1 = islands[idx1].pos
		var p2 = islands[idx2].pos
		
		if count == 1:
			# 单线
			draw_line(p1, p2, Color.WHITE, 4.0)
		elif count == 2:
			# 双线：计算一个垂直偏移量，画两条平行的线
			var dir = (p2 - p1).normalized()
			var offset = Vector2(-dir.y, dir.x) * 6.0
			draw_line(p1 + offset, p2 + offset, Color.WHITE, 3.0)
			draw_line(p1 - offset, p2 - offset, Color.WHITE, 3.0)

	# 2. 画所有的岛（圆）和数字
	for i in range(islands.size()):
		var isl = islands[i]
		# 如果被选中，颜色变红，否则是淡蓝色
		var color = Color(1, 0.3, 0.3) if i == selected_island else Color(0.3, 0.8, 1.0)
		
		# 画圆
		draw_circle(isl.pos, 35, color)
		
		# 画数字（黑色字体）
		var text = str(isl.target)
		var font = ThemeDB.fallback_font
		draw_string(font, isl.pos + Vector2(-8, 10), text, HORIZONTAL_ALIGNMENT_CENTER, -1, 24, Color.BLACK)

# ================= 输入交互逻辑 =================
func _input(event):
	# 只处理鼠标左键点击
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		for i in range(islands.size()):
			# 判断点击是否落在了圆的半径内
			if event.position.distance_to(islands[i].pos) < 35:
				_handle_island_click(i)
				queue_redraw() # 重绘画面
				get_viewport().set_input_as_handled() # 拦截事件
				return
				
		# 如果点到了空白处，取消选中
		selected_island = -1
		queue_redraw()

func _handle_island_click(idx: int):
	if selected_island == -1:
		# 第一次点击：选中
		selected_island = idx
	elif selected_island == idx:
		# 点击自己：取消选中
		selected_island = -1
	else:
		# 点击了另一个岛：尝试连线
		_try_connect(selected_island, idx)
		selected_island = -1

func _try_connect(a: int, b: int):
	var p1 = islands[a].pos
	var p2 = islands[b].pos
	
	# 规则1：只能水平或垂直连
	if p1.x != p2.x and p1.y != p2.y:
		print("不能斜着连！")
		return
		
	# 规则2：中间不能被其他岛挡住
	for i in range(islands.size()):
		if i == a or i == b: continue
		if _is_between(p1, p2, islands[i].pos):
			print("被其他岛挡住了，不能连！")
			return

	# 检查是否已经有桥了
	for bridge in bridges:
		if (bridge[0] == a and bridge[1] == b) or (bridge[0] == b and bridge[1] == a):
			# 状态循环：单线 -> 双线 -> 取消
			bridge[2] += 1
			if bridge[2] > 2: # 超过2条就拆掉
				bridges.erase(bridge)
			_update_currents()
			return

	# 新建单线桥
	bridges.append([a, b, 1])
	_update_currents()

func _is_between(p1: Vector2, p2: Vector2, p: Vector2) -> bool:
	# 判断点 p 是否在 p1 到 p2 的线段中间
	if p1.x == p2.x and p.x == p1.x:
		return min(p1.y, p2.y) < p.y and p.y < max(p1.y, p2.y)
	if p1.y == p2.y and p.y == p1.y:
		return min(p1.x, p2.x) < p.x and p.x < max(p1.x, p2.x)
	return false

func _update_currents():
	# 每次连线变化，重新计算每个岛当前的连线数
	for isl in islands:
		isl.current = 0
	for bridge in bridges:
		islands[bridge[0]].current += bridge[2]
		islands[bridge[1]].current += bridge[2]

# ================= 提交校验 =================
func _on_submit():
	for isl in islands:
		if isl.current != isl.target:
			print("连线数量不对！")
			$SubmitButton.text = "错误，再试试！"
			await get_tree().create_timer(1.5).timeout
			$SubmitButton.text = "确认连线"
			return
			
	# 全部匹配正确
	print("解谜成功！")
	closed.emit()
	queue_free()

# ================= 关闭 =================
func _on_close():
	closed.emit()
	queue_free()
