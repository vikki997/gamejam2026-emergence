extends Control

signal closed
# ★ 核心修改 1：新增专属的通关成功信号
signal puzzle_solved 

# 定义桥的颜色：蓝色、青色、玫红、浅蓝、橙色
const BRIDGE_COLORS = [
	Color(0.0, 0.6, 1.0),    # 亮蓝色
	Color(0.0, 1.0, 1.0),    # 青色
	Color(1.0, 0.2, 0.6),    # 玫红色
	Color(0.6, 0.8, 1.0),    # 浅蓝色
	Color(1.0, 0.6, 0.0)     # 橙色
]

var all_levels = []
var current_level_idx = 0
var islands = []
var bridges = []
var selected_island = -1

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	$SubmitButton.pressed.connect(_on_submit)
	$CloseButton.pressed.connect(_on_close)
	
	_generate_levels()
	_load_level(0)

# ================= 根据屏幕比例动态生成坐标 =================
func _generate_levels():
	var screen = get_viewport_rect().size
	
	# 强制取整，防止浮点数误差导致无法水平/垂直连线
	var cx = round(screen.x * 0.45)
	var cy = round(screen.y * 0.5)
	var dx = round(min(150, screen.x * 0.15))
	var dy = round(min(150, screen.y * 0.2))
	
	all_levels = [
		# 关卡 1
		{
			"islands": [
				{"pos": Vector2(cx - dx, cy), "target": 2},
				{"pos": Vector2(cx, cy), "target": 5},
				{"pos": Vector2(cx + dx, cy), "target": 2},
				{"pos": Vector2(cx, cy - dy), "target": 1}
			]
		},
		# 关卡 2
		{
			"islands": [
				{"pos": Vector2(cx - dx, cy - dy), "target": 3},
				{"pos": Vector2(cx, cy - dy), "target": 4},
				{"pos": Vector2(cx + dx, cy - dy), "target": 2},
				{"pos": Vector2(cx - dx, cy + dy), "target": 3},
				{"pos": Vector2(cx, cy + dy), "target": 4},
				{"pos": Vector2(cx + dx, cy + dy), "target": 2}
			]
		},
		# 关卡 3
		{
			"islands": [
				{"pos": Vector2(cx - dx, cy - dy), "target": 3},
				{"pos": Vector2(cx, cy - dy), "target": 4},
				{"pos": Vector2(cx + dx, cy - dy), "target": 3},
				{"pos": Vector2(cx - dx, cy + round(dy*0.5)), "target": 3},
				{"pos": Vector2(cx, cy + round(dy*0.5)), "target": 6},
				{"pos": Vector2(cx + dx, cy + round(dy*0.5)), "target": 3},
				{"pos": Vector2(cx, cy + round(dy*1.5)), "target": 2}
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
		
	queue_redraw()

# ================= 绘制逻辑 =================
func _draw():
	# 1. 画桥（带颜色）
	for bridge in bridges:
		var idx1 = bridge[0]
		var idx2 = bridge[1]
		var count = bridge[2]
		
		var p1 = islands[idx1].pos
		var p2 = islands[idx2].pos
		
		# 用两个岛屿的索引相加，分配固定的颜色
		var color_idx = abs(idx1 + idx2) % BRIDGE_COLORS.size()
		var bridge_color = BRIDGE_COLORS[color_idx]
		
		if count == 1:
			draw_line(p1, p2, bridge_color, 4.0)
		elif count == 2:
			var dir = (p2 - p1).normalized()
			var offset = Vector2(-dir.y, dir.x) * 6.0
			draw_line(p1 + offset, p2 + offset, bridge_color, 3.0)
			draw_line(p1 - offset, p2 - offset, bridge_color, 3.0)

	# 2. 画岛和数字
	var font = ThemeDB.fallback_font
	var font_size = 28
	
	for i in range(islands.size()):
		var isl = islands[i]
		var color = Color(1, 0.3, 0.3) if i == selected_island else Color(0.3, 0.8, 1.0)
		
		draw_circle(isl.pos, 35, color)
		
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
	
	# 使用绝对值容差判定，防止因为微小误差导致判定为斜线
	if abs(p1.x - p2.x) > 1.0 and abs(p1.y - p2.y) > 1.0:
		return 
		
	for i in range(islands.size()):
		if i == a or i == b: continue
		if _is_between(p1, p2, islands[i].pos):
			return 

	# 安全地查找并修改桥
	var found_bridge = null
	for bridge in bridges:
		if (bridge[0] == a and bridge[1] == b) or (bridge[0] == b and bridge[1] == a):
			found_bridge = bridge
			break
			
	if found_bridge != null:
		found_bridge[2] += 1
		if found_bridge[2] > 2:
			bridges.erase(found_bridge)
		_update_currents()
		return

	# 新建桥
	bridges.append([a, b, 1])
	_update_currents()

func _is_between(p1: Vector2, p2: Vector2, p: Vector2) -> bool:
	if abs(p1.x - p2.x) < 1.0 and abs(p.x - p1.x) < 1.0:
		return min(p1.y, p2.y) < p.y and p.y < max(p1.y, p2.y)
	if abs(p1.y - p2.y) < 1.0 and abs(p.y - p1.y) < 1.0:
		return min(p1.x, p2.x) < p.x and p.x < max(p1.x, p2.x)
	return false

func _update_currents():
	for isl in islands: isl.current = 0
	for bridge in bridges:
		islands[bridge[0]].current += bridge[2]
		islands[bridge[1]].current += bridge[2]

# ================= 提交校验 =================
func _on_submit():
	$SubmitButton.disabled = true
	
	var is_correct = true
	for isl in islands:
		if isl.current != isl.target:
			is_correct = false
			break
			
	if not is_correct:
		$SubmitButton.modulate = Color(1, 0.4, 0.4, 0.7)
		await get_tree().create_timer(1.0).timeout
		$SubmitButton.modulate = Color(1, 1, 1, 1)
		$SubmitButton.disabled = false
		return
		
	$SubmitButton.modulate = Color(0.5, 0.5, 0.5)
	await get_tree().create_timer(1.0).timeout
	
	if current_level_idx < all_levels.size() - 1:
		# 还没到最后一关，进入下一关
		_load_level(current_level_idx + 1)
		$SubmitButton.modulate = Color(1, 1, 1, 1)
		$SubmitButton.disabled = false
	else:
		# ★ 核心修改 2：所有关卡通关，发出信号！
		print("所有谜题解谜成功！")
		puzzle_solved.emit() 
		closed.emit()
		queue_free()

# ================= 关闭 =================
func _on_close():
	closed.emit()
	queue_free()
