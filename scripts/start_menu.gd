extends Control

# 获取黑色遮罩节点
@onready var black_mask: ColorRect = $BlackMask

func _ready():
	# 游戏启动：黑屏慢慢淡出，显示菜单画面
	var tween = create_tween()
	tween.tween_property(black_mask, "modulate:a", 0, 1.2)


# 【开始游戏按钮】点击触发
func _on_start_button_pressed():
	# 重置全局游戏数据，开局清空收集物品状态
	GameManager.fragments_collected = 0
	GameManager.has_key = false
	GameManager.diary_unlocked = false

	var tween = create_tween()
	tween.tween_property(black_mask, "modulate:a", 1, 0.8) # 画面慢慢变黑
	await tween.finished # 等待黑屏动画播放完成

	# 调用队友写好的场景跳转函数，进入孩子房间
	GameManager.go_to_room("child_room")


# 【设置按钮】点击触发（现在只是占位，后续做设置界面再扩展）
func _on_option_button_pressed():
	print("准备打开设置面板")


# 【退出按钮】点击触发，关闭游戏窗口
func _on_quit_button_pressed():
	get_tree().quit()
