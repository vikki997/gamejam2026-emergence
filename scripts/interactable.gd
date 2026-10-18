extends Control

signal closed

var all_levels = []
var current_level_idx = 0
var islands = []
var bridges = []
var selected_island = -1

func _ready():
	$SubmitButton.pressed.connect(_on_submit)
	$CloseButton.pressed.connect(_on_close)
	_generate_levels()
	_load_level(0)

# ================= 根据屏幕大小动态生成坐标 =================
func _generate_levels():
	var screen = get_viewport_rect().size
	var cx = screen.x / 2.0
	var cy = screen.y / 2.0
	
	all_levels = [
		# 关卡 1：入门（4个岛）
		{
			"islands": [
				{"pos": Vector2(cx - 200, cy), "target": 2}, # 0: 左
				{"pos": Vector2(cx, cy), "target": 5},       # 1: 中
				{"pos": Vector2(cx + 200, cy), "target": 2}, # 2: 右
				{"pos": Vector2(cx, cy - 200), "target": 1}  # 3: 上
			]
		},
		# 关卡 2：进阶（6个岛）
		{
			"islands": [
				{"pos": Vector2(cx - 200, cy - 150), "target": 3}, # 0: 左上
				{"pos": Vector2(cx, cy - 150), "target": 4},       # 1: 中上
				{"pos": Vector2(cx + 200, cy - 150), "target": 2}, # 2: 右上
				{"pos": Vector2(cx - 200, cy + 150), "target": 3}, # 3: 左下
				{"pos": Vector2(cx, cy + 150), "target": 4},       # 4: 中下
				{"pos": Vector2(cx + 200, cy + 150), "target": 2}  # 5: 右下
			]
		},
		# 关卡 3：挑战（7个岛）
		{
			"islands": [
				{"pos": Vector2(cx - 250, cy - 200), "target": 3}, # 0: 左上
				{"pos": Vector2(cx, cy - 200), "target": 3},       # 1: 中上
				{"pos": Vector2(cx + 250, cy - 200), "target": 3}, # 2: 右上
				{"pos": Vector2(cx - 250, cy + 50), "target": 4},  # 3: 左下
				{"pos": Vector2(cx, cy + 50), "target": 5},        # 4: 中下
				{"pos": Vector2(cx + 250, cy + 50), "target": 4},  # 5: 右下
				{"pos": Vector2(cx, cy + 250), "target": 4}        # 6: 最下
			]
		}
	]

# ================= 加载关卡 =================
func _load_level(idx):
	current_level_idx = idx
	bridges.clear()
	selected_island = -1
	
	islands.clear()
	for item in all_levels[idx]["islands"]:
		islands.append({
			"pos": item["pos"],
			"target": item["target"],
			"current": 0
		})
		
	$SubmitButton.text = "确认连线"
	queue_redraw()

# ================= 绘制逻辑 =================
func _draw():
	# 1. 画桥
	for bridge in bridges:
		var idx1 = bridge[0]
		var idx2 = bridge[1]
		var count = bridge[2]
		
		var p1 = islands[idx1].pos
		var p2 = islands[idx2].pos
		
		if count == 1:
			draw_line(p1, p2, Color.WHITE, 4.0)
		elif count == 2:
			var dir = (p2 - p1).normalized()
			var offset = Vector2(-dir.y, dir.x) * 6.0
			draw_line(p1 + offset, p2 + offset, Color.WHITE, 3.0)
			draw_line(p1 - offset, p2 - offset, Color.WHITE, 3.0)

	# 2. 画岛和数字
	var font = ThemeDB.fallback_font
	var font_size = 28
	
	for i in range(islands.size()):
		var isl = islands[i]
		var color = Color(1, 0.3, 0.3) if i == selected_island else Color(0.3, 0.8, 1.0)
		
		# 画圆
		draw_circle(isl.pos, 35, color)
		
		# 精确计算文字居中
		var text = str(isl.target)
		var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		var text_pos = isl.pos - Vector2(text_size.x / 2.0, -text_size.y / 4.0)
		
		draw_string(font, text_pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.BLACK)

# ================= 输入交互 =================
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		for i in range(islands.size()):
			if event.position.distance_to(islands[i].pos) < 35:
				_handle_island_click(i)
				queue_redraw()
				get_viewport().set_input_as_handled()
				return
		selected_island = -1
		queue_redraw()

func _handle_island_click(idx: int):
	if selected_island == -1:
		selected_island = idx
	elif selected_island == idx:
		selected_island = -1
	else:
		_try_connect(selected_island, idx)
		selected_island = -1

func _try_connect(a: int, b: int):
	var p1 = islands[a].pos
	var p2 = islands[b].pos
	
	if p1.x != p2.x and p1.y != p2.y:
		return # 不能斜连
		
	for i in range(islands.size()):
		if i == a or i == b: continue
		if _is_between(p1, p2, islands[i].pos):
			return # 不能跨越其他岛

	for bridge in bridges:
		if (bridge[0] == a and bridge[1] == b) or (bridge[0] == b and bridge[1] == a):
			bridge[2] += 1
			if bridge[2] > 2:
				bridges.erase(bridge)
			_update_currents()
			return

	bridges.append([a, b, 1])
	_update_currents()

func _is_between(p1: Vector2, p2: Vector2, p: Vector2) -> bool:
	if p1.x == p2.x and p.x == p1.x:
		return min(p1.y, p2.y) < p.y and p.y < max(p1.y, p2.y)
	if p1.y == p2.y and p.y == p1.y:
		return min(p1.x, p2.x) < p.x and p.x < max(p1.x, p2.x)
	return false

func _update_currents():
	for isl in islands: isl.current = 0
	for bridge in bridges:
		islands[bridge[0]].current += bridge[2]
		islands[bridge[1]].current += bridge[2]

# ================= 提交校验 =================
func _on_submit():
	for isl in islands:
		if isl.current != isl.target:
			$SubmitButton.text = "数量不对！"
			await get_tree().create_timer(1.0).timeout
			$SubmitButton.text = "确认连线"
			return
			
	if current_level_idx < all_levels.size() - 1:
		$SubmitButton.text = "进入下一关..."
		await get_tree().create_timer(1.5).timeout
		_load_level(current_level_idx + 1)
	else:
		print("所有谜题解谜成功！")
		closed.emit()
		queue_free()

# ================= 关闭 =================
func _on_close():
	closed.emit()
	queue_free()
	
