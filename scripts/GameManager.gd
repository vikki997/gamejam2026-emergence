extends Node

var fragments_collected = 0
var has_key = false
var diary_unlocked = false
var coatrack_solved = false

func unlock_diary():
	diary_unlocked = true
	
# 重置全部游戏状态（菜单点击开始游戏时调用）
func reset_game():
	fragments_collected = 0
	has_key = false
	diary_unlocked = false
	print("游戏状态已全部重置")

func go_to_room(room_name: String):
	match room_name:
		"child_room":
			get_tree().change_scene_to_file("res://scenes/Child's room.tscn")
		"parent_room":
			get_tree().change_scene_to_file("res://scenes/rooms/ParentRoom.tscn")
		"living_room":
			get_tree().change_scene_to_file("res://scenes/living room.tscn")
			
