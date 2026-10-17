extends CanvasLayer

# 道具 ID 对应的图片路径
const ITEM_ICONS = {
	"key": "res://art/zoom/rack/key.png",
	"fragment1": "res://art/photo/fragment1.png",
	"fragment2": "res://art/photo/fragment2.png",
	"fragment3": "res://art/photo/fragment3.png",
	"fragment4": "res://art/photo/fragment4.png"
}

# 获取五个格子节点
@onready var slots = [
	$Panel/SlotGrid/Slot1,
	$Panel/SlotGrid/Slot2,
	$Panel/SlotGrid/Slot3,
	$Panel/SlotGrid/Slot4,
	$Panel/SlotGrid/Slot5,
]

func _ready():
	# 监听 GameManager 的道具变化信号
	GameManager.inventory_changed.connect(_refresh_inventory)
	
	# ★ 初始化时，强制把所有格子的 Icon 铺满并设置好缩放规则
	for slot in slots:
		if slot == null:
			continue
		var icon_node = slot.get_node_or_null("Icon")
		if icon_node:
			_setup_icon_node(icon_node)
			
	# 初始刷新一次
	_refresh_inventory()

func _refresh_inventory():
	# 1. 先把所有格子里的图片清空
	for slot in slots:
		# 防呆：如果找不到格子，跳过不报错
		if slot == null:
			continue
		var icon_node = slot.get_node_or_null("Icon")
		if icon_node:
			icon_node.texture = null

	# 2. 按照 GameManager 里的物品顺序，一个个放进格子里
	var inventory_items = GameManager.inventory
	for i in range(inventory_items.size()):
		# 如果物品数量超过格子数量，就放不下了
		if i >= slots.size():
			break
			
		var item_id = inventory_items[i]
		if not ITEM_ICONS.has(item_id):
			push_warning("物品栏找不到这个物品的图片：" + item_id)
			continue
			
		# 把图片塞进第 i 个格子的 Icon 节点里
		var slot = slots[i]
		if slot == null:
			continue
		var icon_node = slot.get_node_or_null("Icon")
		if icon_node:
			icon_node.texture = load(ITEM_ICONS[item_id])
			_setup_icon_node(icon_node)

# ★ 抽取成一个独立函数，统一处理图标的防变形和居中
func _setup_icon_node(icon_node: TextureRect):
	# 强制让 Icon 铺满所在的 PanelContainer 格子
	icon_node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# 忽略原本尺寸
	icon_node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	# 保持比例缩放，并居中显示（核心防变形）
	icon_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
