extends Node

# ========== 游戏进度数据 ==========
var fragments_collected = 0
var has_key = false
var diary_unlocked = false
var coat_rack_solved = false
var tv_solved = false
var is_transitioning = false 

# ★ 剧情流程状态变量（刚才加的，非常关键）
var is_cutscene = false       # 剧情锁：是否正在播放剧情（禁止玩家乱点）
var notebook_read = false     # 状态记录：是否在卧室看过笔记本
var crow_seen = false         # 状态记录：是否在客厅看过乌鸦人并转白天
var photo_completed = false   # 状态记录：是否拼完了全家福

# ========== 物品栏 ==========
var inventory = []
signal inventory_changed

func add_item(item_id: String):
	if item_id in inventory:
		return
	inventory.append(item_id)
	inventory_changed.emit()

func has_item(item_id: String) -> bool:
	return item_id in inventory

# ========== BGM ==========
var bgm_day: AudioStreamPlayer

func _ready():
	bgm_day = AudioStreamPlayer.new()
	add_child(bgm_day)
	bgm_day.volume_db = -8
	bgm_day.bus = "BGM"
	var day_audio: AudioStreamMP3 = load("res://sounds/daymusic.mp3")
	if day_audio:
		day_audio.loop = true
		bgm_day.stream = day_audio
		bgm_day.play()

# ========== 日记本 ==========
func unlock_diary():
	diary_unlocked = true

# ========== 重置 ==========
func reset_game():
	fragments_collected = 0
	has_key = false
	diary_unlocked = false
	coat_rack_solved = false
	tv_solved = false
	is_transitioning = false
	
	# ★ 重置剧情状态，防止新游戏串档
	is_cutscene = false
	notebook_read = false
	crow_seen = false
	photo_completed = false
	
	inventory.clear()
	inventory_changed.emit()
	print("游戏状态已全部重置")

# ========== 房间跳转 ==========
func go_to_room(room_name: String):
	if is_transitioning:
		return
	is_transitioning = true
	
	var path = ""
	match room_name:
		"child_room":
			path = "res://scenes/rooms/Child's room.tscn"
		"parent_room":
			path = "res://scenes/rooms/ParentRoom.tscn"
		"living_room":
			path = "res://scenes/rooms/Living room.tscn"
			
	if not ResourceLoader.exists(path):
		push_error("【致命错误】找不到场景文件：" + path)
		is_transitioning = false
		return

	print(">>> 正在切向: ", path)
	
	# 1. 黑屏
	await fade_black() 
	
	# 2. 切换场景
	get_tree().change_scene_to_file(path)
	
	# 3. 等待 0.1 秒（给新场景的 _ready 留足时间）
	await get_tree().create_timer(0.1).timeout
	
	if get_tree().current_scene:
		print(">>> 当前已成功加载场景：", get_tree().current_scene.name)
	else:
		print(">>> 警告：current_scene 为空！目标场景可能崩溃了。")
	
	# 4. 渐出黑屏
	await fade_out_black()
	
	# 5. 解锁
	is_transitioning = false

# ========== 黑屏转场 ==========
var black_mask: ColorRect 
var transition_layer: CanvasLayer 

func fade_black() -> void:
	if black_mask and is_instance_valid(black_mask):
		black_mask.get_parent().queue_free()
		
	transition_layer = CanvasLayer.new()
	transition_layer.layer = 999 
	get_tree().root.add_child(transition_layer)
	
	black_mask = ColorRect.new()
	black_mask.color = Color(0, 0, 0, 0)
	
	black_mask.set_anchors_preset(Control.PRESET_FULL_RECT)
	black_mask.size = get_viewport().get_visible_rect().size
	
	transition_layer.add_child(black_mask)
	
	var tween = create_tween()
	tween.tween_property(black_mask, "color:a", 1, 0.4) 
	await tween.finished

func fade_out_black() -> void:
	if black_mask and is_instance_valid(black_mask):
		var tween = create_tween()
		tween.tween_property(black_mask, "color:a", 0, 0.4) 
		await tween.finished
		
		if transition_layer and is_instance_valid(transition_layer):
			transition_layer.queue_free()
			
		black_mask = null
