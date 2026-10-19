extends ColorRect

func _process(delta):
	# 获取鼠标在屏幕上的位置
	var mouse_pos = get_local_mouse_position()
	# 转成shader要用的UV坐标
	var uv_center = mouse_pos / get_rect().size
	material.set_shader_parameter("center", uv_center)
