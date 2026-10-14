extends Control

signal closed

# ========== 常量 ==========

# 吸附范围：衣服距离分支多近时吸附
const SNAP_RANGE = 80.0

# 三个角度的衣架贴图
const RACK_TEXTURES = [
	preload("res://art/zoom/rack/rack_front.png"),
	preload("res://art/zoom/rack/rack_front.png"),
	preload("res://art/zoom/rack/rack_front.png"),
]

# 每个角度下，5个分支的位置（相对于 RackArea 的局部坐标）
# 这些坐标需要根据你的衣架图片调整
const BRANCH_POSITIONS = {
	0: [Vector2(80, 100), Vector2(140, 130), Vector2(200, 160), Vector2(260, 190), Vector2(320, 220)],
	1: [Vector2(100, 180), Vector2(160, 150), Vector2(220, 120), Vector2(280, 90), Vector2(340, 60)],
	2: [Vector2(80, 60), Vector2(140, 90), Vector2(200, 120), Vector2(260, 150), Vector2(320, 180)],
}

# 正确解：角度0，蓝色外套=分支0，青色毛衣=分支1，粉色裙子=分支2，帽子=分支3
const SOLUTION = {
	"blue_coat": 0,
	"teal_sweater": 1,
	"pink_skirt": 2,
	"hat": 3,
}

# 衣服正常形态贴图
const CLOTH_NORMAL = {
	"blue_coat": preload("res://art/zoom/rack/rack_front.png"),
	"teal_sweater": preload("res://art/zoom/rack/rack_front.png"),
	"pink_skirt": preload("res://art/zoom/rack/rack_front.png"),
	"hat": preload("res://art/zoom/rack/rack_front.png"),
}

# 衣服折叠形态贴图（帽子不变）
const CLOTH_FOLDED = {
	"blue_coat": preload("res://art/zoom/rack/blue_coat_folded.png"),
	"teal_sweater": preload("res://art/zoom/rack/teal_sweater_folded.png"),
	"pink_skirt": preload("res://art/zoom/rack/pink_skirt_folded.png"),
	"hat": preload("res://art/zoom/rack/hat.png"),
}

# ========== 状态变量 ==========

var current_angle = 0
var placed_clothes = {}       # {cloth_id: branch_index}
var dragged_cloth = null      # 当前拖动的衣服 id
var drag_offset = Vector2.ZERO
var rack_dragging = false
var rack_drag_start = 0.0
var solved = false
var clothes_revealed = false  # 衣服是否已展开

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
	$Content/RackArea/RackSprite.gui_input.connect(_on_rack_gui_input)

	# 记录每件衣服的初始位置
	for cloth_id in cloth_nodes:
		original_positions[cloth_id] = cloth_nodes[cloth_id].position

	# 连接每件衣服的输入
	for cloth_id in cloth_nodes:
		cloth_nodes[cloth_id].gui_input.connect(_on_cloth_gui_input.bind(cloth_id))

	# 初始隐藏衣服（衣服还在堆里）
	for cloth in cloth_nodes.values():
		cloth.visible = false

	# 隐藏钥匙
	key.visible = false

	# 更新衣架贴图
	update_rack_texture()

	# 如果已经解开过，直接显示解谜后状态
	if GameManager.coat_rack_solved:
		solved = true
		clothes_revealed = true
		clothes_pile.visible = false
		for cloth in cloth_nodes.values():
			cloth.visible = false  # 已挂好，不显示在底部

# ========== 衣架旋转 ==========

func _on_rack_gui_input(event):
	if solved:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# 如果衣服还没展开，点击后展开
			if not clothes_revealed:
				reveal_clothes()
				return
			rack_dragging = true
			rack_drag_start = event.position.x
		else:
			if rack_dragging:
				rack_dragging = false
				var delta = event.position.x - rack_drag_start
				if abs(delta) > 50:
					rotate_rack()

func rotate_rack():
	# 如果有衣服挂在衣架上，全部回到原位
	reset_all_clothes()
	# 旋转到下一个角度
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
			drag_offset = event.position
			var cloth = cloth_nodes[cloth_id]

			# 如果衣服已经在分支上，先移除，变回正常形态
			if cloth_id in placed_clothes:
				placed_clothes.erase(cloth_id)
				set_cloth_normal(cloth_id)

			cloth.modulate = Color(1.2, 1.2, 1.2)  # 高亮
		else:
			if dragged_cloth == cloth_id:
				dragged_cloth = null
				var cloth = cloth_nodes[cloth_id]
				cloth.modulate = Color(1, 1, 1)
				try_place_cloth(cloth_id)

func try_place_cloth(cloth_id: String):
	var cloth = cloth_nodes[cloth_id]
	var cloth_global = cloth.global_position

	# 找最近的分支
	var nearest_branch = -1
	var nearest_dist = SNAP_RANGE
	var branch_positions = BRANCH_POSITIONS[current_angle]
	var rack_origin = $Content/RackArea.global_position

	for i in range(branch_positions.size()):
		var branch_global = rack_origin + branch_positions[i]
		var dist = cloth_global.distance_to(branch_global)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest_branch = i

	if nearest_branch >= 0:
		# 检查分支是否已被占
		var occupied = false
		for cid in placed_clothes:
			if placed_clothes[cid] == nearest_branch:
				occupied = true
				break

		if not occupied:
			placed_clothes[cloth_id] = nearest_branch
			var branch_global = rack_origin + branch_positions[nearest_branch]
			cloth.global_position = branch_global
			set_cloth_folded(cloth_id)
			check_solution()
			return

	# 没吸附，回到原位
	return_cloth(cloth_id)

func return_cloth(cloth_id: String):
	var cloth = cloth_nodes[cloth_id]
	cloth.position = original_positions[cloth_id]
	set_cloth_normal(cloth_id)

func reset_all_clothes():
	for cloth_id in cloth_nodes:
		placed_clothes.erase(cloth_id)
		return_cloth(cloth_id)

# ========== 衣服形态 ==========

func set_cloth_folded(cloth_id: String):
	cloth_nodes[cloth_id].texture = CLOTH_FOLDED[cloth_id]

func set_cloth_normal(cloth_id: String):
	cloth_nodes[cloth_id].texture = CLOTH_NORMAL[cloth_id]

# ========== 检查答案 ==========

func check_solution():
	if placed_clothes.size() < 4:
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
		key.visible = true
		key.gui_input.connect(_on_key_clicked)
		GameManager.coat_rack_solved = true
	else:
		await get_tree().create_timer(0.5).timeout
		reset_all_clothes()

# ========== 钥匙 ==========

func _on_key_clicked(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		key.visible = false
		GameManager.add_item("key")
		GameManager.has_key = true

# ========== 关闭 ==========

func _on_close():
	closed.emit()
	queue_free()

# ========== 处理拖动中的衣服 ==========

func _process(_delta):
	if dragged_cloth:
		var cloth = cloth_nodes[dragged_cloth]
		var mouse_pos = get_global_mouse_position()
		cloth.global_position = mouse_pos - drag_offset
