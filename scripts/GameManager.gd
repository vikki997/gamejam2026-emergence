extends Node

var fragments_collected = 0
var has_key = false
var diary_unlocked = false

func unlock_diary():
	diary_unlocked = true

func go_to_room(room_name: String):
	match room_name:
		"child_room":
			get_tree().change_scene_to_file("res://scenes/Child's room.tscn")
		"parent_room":
			get_tree().change_scene_to_file("res://scenes/rooms/ParentRoom.tscn")
		"living_room":
			get_tree().change_scene_to_file("res://scenes/living room.tscn")
			
