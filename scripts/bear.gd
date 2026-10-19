extends AnimatedSprite2D

# 右边检查器，你已经拖好了
@export var tip_label: Label
@export var dialog_box: Sprite2D

var intro_played: bool = false

func _ready():
	play("idle")
	await get_tree().create_timer(1.0).timeout
	if !intro_played:
		play_intro_dialog()

func play_intro_dialog():
	intro_played = true
	show_tip("（小熊）欢迎来到这里。仔细观察房间里的一切。")

func _input_event(viewport, event, shape_idx):
	if event.is_action_pressed("mouse_left"):
		play("click")
		await animation_finished
		play("idle")
		show_tip("（小熊）你可以点击房间里的物品，寻找线索。")

func show_tip(text: String):
	if tip_label == null || dialog_box == null:
		print("⚠️ 检查器面板没有拖入tip_label / dialog_box！")
		return
	
	tip_label.text = text
	tip_label.visible = true
	dialog_box.visible = true
	
	await get_tree().create_timer(3.0).timeout
	
	tip_label.visible = false
	dialog_box.visible = false
