extends Control

@onready var black_mask: ColorRect = $BlackMask

func _ready():
	# 游戏启动：黑屏慢慢淡出，显示菜单画面
	var tween = create_tween()
	tween.tween_property(black_mask, "modulate:a", 0, 1.2)

func _on_start_button_pressed():
	# ★ 核心修改1：一键清空所有数据（碎片、物品栏、解谜进度等）
	GameManager.reset_game()
	
	# ★ 核心修改2：直接调用跳转，把黑屏交给我们写好的全局函数处理
	GameManager.go_to_room("child_room")

func _on_option_button_pressed():
	print("准备打开设置面板")

func _on_quit_button_pressed():
	get_tree().quit()
