extends Node2D

func _ready():
	# 每次进入客厅场景时，自动检查一次碎片4的状态
	update_fragment4()

# 这个函数专门用来控制碎片4的显隐
# 它会在两个时机被触发：
# 1. 刚进入客厅时（_ready 里面调用）
# 2. 电视特写关闭时（TV.gd 里面调用）
func update_fragment4():
	var frag4 = get_node_or_null("Interactables/Fragment4")
	
	if frag4:
		# 如果电视解谜成功，且玩家物品栏里还没有碎片4，就显示它
		if GameManager.tv_solved and not GameManager.has_item("fragment4"):
			frag4.visible = true
		else:
			# 否则就隐藏它（比如还没解谜，或者已经捡过了）
			frag4.visible = false
