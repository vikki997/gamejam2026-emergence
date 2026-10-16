extends Node

# ========== 游戏进度数据 ==========

var fragments_collected = 0
var has_key = false
var diary_unlocked = false
var coat_rack_solved = false

# ========== 物品栏 ==========

# 物品栏，存道具 id，比如 "key"
var inventory = []

# 道具栏变化信号，UI 收到后刷新
signal inventory_changed

# 添加道具
func add_item(item_id: String):
	if item_id in inventory:
		return
	inventory.append(item_id)
	inventory_changed.emit()

# 检查是否有某个道具
func has_item(item_id: String) -> bool:
	return item_id in inventory

# ========== BGM ==========

var bgm_day: AudioStreamPlayer

func _ready():
	# 白天BGM播放器
	bgm_day = AudioStreamPlayer.new()
	add_child(bgm_day)
	bgm_day.volume_db = -8

	var day_audio: AudioStreamMP3 = load("res://sounds/daymusic.mp3")
	day_audio.loop = true
	bgm_day.stream = day_audio
	bgm_day.play()

# ========== 日记本 ==========

func unlock_diary():
	diary_unlocked = true

# ========== 重置 ==========

# 重置全部游戏状态（菜单点击开始游戏时调用）
func reset_game():
	fragments_collected = 0
	has_key = false
	diary_unlocked = false
	coat_rack_solved = false
	inventory.clear()
	inventory_changed.emit()
	print("游戏状态已全部重置")

# ========== 房间跳转 ==========

# 统一房间跳转函数（自带黑屏转场）
# 你门的脚本以后调用这个，而不是自己 change_scene
func go_to_room(room_name: String):
	await fade_black() # 先黑屏
	match room_name:
		"child_room":
			get_tree().change_scene_to_file("res://scenes/rooms/Child's room.tscn")
		"parent_room":
			get_tree().change_scene_to_file("res://scenes/rooms/ParentRoom.tscn")
		"living_room":
			get_tree().change_scene_to_file("res://scenes/rooms/Living room.tscn")

# ========== 黑屏转场 ==========

# 全局黑屏转场，所有房间共用
func fade_black() -> void:
	var black_mask = ColorRect.new()
	black_mask.color = Color(0, 0, 0, 0)
	black_mask.z_index = 999
	get_tree().root.add_child(black_mask)

	var tween = get_tree().create_tween()
	tween.tween_property(black_mask, "color:a", 1, 0.4) # 0.4秒变黑
	await tween.finished
	black_mask.queue_free() # 销毁遮罩，防止叠加
