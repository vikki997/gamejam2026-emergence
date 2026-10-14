extends Node
var fragments_collected = 0
var has_key = false
var diary_unlocked = false
var coatrack_solved = false

var bgm_day: AudioStreamPlayer

func _ready():
	# 白天BGM播放器
	bgm_day = AudioStreamPlayer.new()
	add_child(bgm_day)
	bgm_day.volume_db = -8
	
	var day_audio:AudioStreamMP3 = load("res://sounds/daymusic.mp3")
	day_audio.loop = true
	bgm_day.stream = day_audio
	bgm_day.play()
	
func unlock_diary():
	diary_unlocked = true
	
# 重置全部游戏状态（菜单点击开始游戏时调用）
func reset_game():
	fragments_collected = 0
	has_key = false
	diary_unlocked = false
	coatrack_solved = false # 补上这个状态重置！
	print("游戏状态已全部重置")

# 统一房间跳转函数（自带黑屏转场）
# 你门的脚本以后调用这个，而不是自己change_scene
func go_to_room(room_name: String):
	await fade_black() # 先黑屏
	match room_name:
		"child_room":
			get_tree().change_scene_to_file("res://scenes/rooms/Child's room.tscn")
		"parent_room":
			get_tree().change_scene_to_file("res://scenes/rooms/ParentRoom.tscn")
		"living_room":
			get_tree().change_scene_to_file("res://scenes/rooms/Living room.tscn")

# 新增：全局黑屏转场，所有房间共用
func fade_black() -> void:
	var black_mask = ColorRect.new()
	black_mask.color = Color(0,0,0,0)
	black_mask.z_index = 999
	get_tree().root.add_child(black_mask)

	var tween = get_tree().create_tween()
	tween.tween_property(black_mask, "color:a", 1, 0.4) # 0.4秒变黑
	await tween.finished
	black_mask.queue_free() # 销毁遮罩，防止叠加
