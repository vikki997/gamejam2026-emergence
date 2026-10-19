extends Node2D

func _ready():
	print("====================")
	print("孩子房间加载成功了！")
	print("====================")
	
	if not GameManager.notebook_read:
		play_intro()

func play_intro():
	print("准备播放剧情！")
	GameManager.is_cutscene = true
	
	var lines = [{"name": "小熊", "text": "测试对话！"}]
	
	if Engine.has_singleton("DialogueUI"):
		print("找到对话系统了！")
		DialogueUI.start_dialogue(lines)
		await DialogueUI.dialogue_finished
	else:
		print("找不到 DialogueUI！")
		await get_tree().create_timer(2.0).timeout
		
	GameManager.is_cutscene = false
	print("剧情结束！")
