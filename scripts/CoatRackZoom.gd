extends Control

signal closed

# ========== 常量 ==========

const SNAP_RANGE = 80.0

const RACK_TEXTURES = [
	preload("res://art/zoom/rack/rack_front.png"),
	preload("res://art/zoom/rack/rack_side.png"),
	preload("res://art/zoom/rack/rack_back.png"),
]

# 正确解：正面衣架（角度0）
# 帽子=分支1，蓝色外套=分支2，粉色裙子=分支3，青色毛衣=分支4
const SOLUTION = {
	"hat": 1,
	"blue_coat": 2,
	"pink_skirt": 3,
	"teal_sweater": 4,
}

const CLOTH_TEXTURES = {
	"blue_coat": preload("res://art/zoom/rack/blue_coat_normal.png"),
	"teal_sweater": preload("res://art/zoom/rack/teal_sweater_normal.png"),
	"pink_skirt": preload("res://art/zoom/rack/pink_skirt_normal.png"),
	"hat": preload("res://art/zoom/rack/hat.png"),
}

const HANG_ADJUST = {
	"blue_coat": Vector2(50, 0),
	"teal_sweater": Vector2(50, 0),
	"pink_skirt": Vector2(55, 0),
	"hat": Vector2(60, 40),
}

# 钥匙掉落起点相对目标位置的偏移
const KEY_DROP_OFFSET = Vector2(0, -250)
# 掉落时长
const KEY_DROP_DURATION = 0.9

# ========== 状态变量 ==========

var current_angle = 0
var placed_clothes = {}
var dragged_cloth = null
var drag_offset = Vector2.ZERO
var rack_dragging = false
var rack_drag_start = 0.0
var solved = false
var clothes_revealed = false

var branch_markers = { 0: [], 1: [], 2: [] }

# ========== 节点引用 ==========

@onready var rack_sprite = $Content/RackArea/RackSprite
@onready var clothes_pile = $Content/RackArea/ClothesPile
@onready var key = $Content/Key

@onready var cloth_nodes = {
	"blue_coat": $Content/ClothesArea/BlueCoat,
	"teal_sweater": $Content/ClothesArea/TealSweater,
	"pink_skirt": $Content/ClothesArea/PinkSkirt,
	"hat": $Content/ClothesArea/Hat,
}

var original_positions = {}

# ========== 初始化 ==========

func _ready():
	$CloseButton.pressed.connect(_on_close)

	clothes_pile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rack_sprite.mouse_filter = Control.MOUSE_FILTER_STOP
	rack_sprite.gui_input.connect(_on_rack_gui_input)

	for angle in range(3):
		for i in range(5):
			var marker_name = "Angle%d_Branch%d" % [angle, i]
			var marker = $Content/RackArea.get_node_or_null(marker_name)
			if marker:
				branch_markers[angle].append(marker)
			else:
				push_warning("缺少 Marker2D: " + marker_name)

	for cloth_id in cloth_nodes:
		var cloth = cloth_nodes[cloth_id]
		if cloth.texture:
			cloth.size = cloth.texture.get_size()
		original_positions[cloth_id] = cloth.position

	for cloth_id in cloth_nodes:
		cloth_nodes[cloth_id].gui_input.connect(_on_cloth_gui_input.bind(cloth_id))

	for cloth in cloth_nodes.values():
		cloth.visible = false

	key.visible = false
	update_rack_texture()

	if GameManager.coat_rack_solved:
		solved = true
		clothes_revealed = true
		clothes_pile.visible = false
		for cloth in cloth_nodes.values():
			cloth.visible = false

# ========== 按下：处理展开和开始旋转 ==========

func _on_rack_gui_input(event):
	if solved:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if not clothes_revealed:
				reveal_clothes()
				return
			rack_dragging = true
			rack_drag_start = get_global_mouse_position().x

# ========== 松开 ==========

func _input(event):
	if solved:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if rack_dragging:
			rack_dragging = false
			var end_x = get_global_mouse_position().x
			var delta = end_x - rack_drag_start
			if abs(delta) > 80:
				rotate_rack()

# ========== 衣架旋转 ==========

func rotate_rack():
	reset_all_clothes()
	current_angle = (current_angle + 1) % 3
	update_rack_texture()

func update_rack_texture():
	rack_sprite.texture = RACK_TEXTURES[current_angle]

# ========== 衣服展开 ==========

func reveal_clothes():
	clothes_revealed = true
	clothes_pile.visible = false
	for cloth in cloth_nodes.values():
		cloth.visible = true

# ========== 拖动衣服 ==========

func _on_cloth_gui_input(event, cloth_id: String):
	if solved:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragged_cloth = cloth_id
			var cloth = cloth_nodes[cloth_id]
			drag_offset = get_global_mouse_position() - cloth.global_position

			if cloth_id in placed_clothes:
				placed_clothes.erase(cloth_id)

			cloth.modulate = Color(1.2, 1.2, 1.2)
		else:
			if dragged_cloth == cloth_id:
				dragged_cloth = null
				var cloth = cloth_nodes[cloth_id]
				cloth.modulate = Color(1, 1, 1)
				try_place_cloth(cloth_id)

# ========== 吸附到分支 ==========

func try_place_cloth(cloth_id: String):
	var cloth = cloth_nodes[cloth_id]

	var hang_offset = Vector2(cloth.size.x / 2.0, 0) + HANG_ADJUST[cloth_id]
	var hang_global = cloth.global_position + hang_offset

	var nearest_branch = -1
	var nearest_dist = SNAP_RANGE
	var markers = branch_markers[current_angle]

	for i in range(markers.size()):
		var branch_global = markers[i].global_position
		var dist = hang_global.distance_to(branch_global)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest_branch = i

	if nearest_branch >= 0:
		var occupied = false
		for cid in placed_clothes:
			if placed_clothes[cid] == nearest_branch:
				occupied = true
				break

		if not occupied:
			placed_clothes[cloth_id] = nearest_branch
			cloth.global_position = markers[nearest_branch].global_position - hang_offset
			check_solution()
			return

	return_cloth(cloth_id)

func return_cloth(cloth_id: String):
	var cloth = cloth_nodes[cloth_id]
	cloth.position = original_positions[cloth_id]

func reset_all_clothes():
	for cloth_id in cloth_nodes:
		placed_clothes.erase(cloth_id)
		return_cloth(cloth_id)

# ========== 检查答案 ==========

func check_solution():
	if placed_clothes.size() < 4:
		return

	# 只有角度0（正面）才算正确
	if current_angle != 0:
		await get_tree().create_timer(0.5).timeout
		reset_all_clothes()
		return

	var correct = true
	for cloth_id in SOLUTION:
		if not cloth_id in placed_clothes:
			correct = false
			break
		if placed_clothes[cloth_id] != SOLUTION[cloth_id]:
			correct = false
			break

	if correct:
		solved = true
		GameManager.coat_rack_solved = true
		drop_key()
	else:
		await get_tree().create_timer(0.5).timeout
		reset_all_clothes()

# ========== 钥匙掉落动画 ==========

func drop_key():
	# 目标位置 = 你在编辑器里给 Key 设置的 Position
	var target_pos = key.position
	# 起始位置 = 目标位置上方
	var start_pos = target_pos + KEY_DROP_OFFSET

	# 设置起始状态
	key.position = start_pos
	key.modulate.a = 0.0
	key.visible = true

	# 创建补间动画
	var tween = create_tween()
	# 先渐显（0.15秒内从透明变不透明）
	tween.tween_property(key, "modulate:a", 1.0, 0.15)
	# 再下落（弹跳缓动，落地有回弹感）
	tween.tween_property(key, "position", target_pos, KEY_DROP_DURATION) \
		.set_trans(Tween.TRANS_BOUNCE) \
		.set_ease(Tween.EASE_OUT)
	# 动画结束，启用点击
	tween.finished.connect(_on_key_landed)

func _on_key_landed():
	# 掉落结束后再连接点击信号，防止掉一半被点到
	key.gui_input.connect(_on_key_clicked)

# ========== 钥匙点击 ==========

func _on_key_clicked(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		key.visible = false
		GameManager.add_item("key")
		GameManager.has_key = true

# ========== 关闭 ==========

func _on_close():
	closed.emit()
	queue_free()

# ========== 拖动 ==========

func _process(_delta):
	if dragged_cloth:
		var cloth = cloth_nodes[dragged_cloth]
		cloth.global_position = get_global_mouse_position() - drag_offset
