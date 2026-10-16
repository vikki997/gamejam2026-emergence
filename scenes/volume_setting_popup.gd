extends PopupPanel

func _ready():
	# 初始化滑块数值，读取当前音量
	$VolumeUIPanel/Slider_Master.value = db_to_linear(AudioServer.get_bus_volume_db(0)) * 100.0
	$VolumeUIPanel/Slider_SFX.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))) * 100.0
	$VolumeUIPanel/Slider_BGM.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("BGM"))) * 100.0

	# 绑定滑块回调
	$VolumeUIPanel/Slider_Master.value_changed.connect(_on_master_changed)
	$VolumeUIPanel/Slider_SFX.value_changed.connect(_on_sfx_changed)
	$VolumeUIPanel/Slider_BGM.value_changed.connect(_on_bgm_changed)
	# 关闭按钮
	$VolumeUIPanel/Btn_Close.pressed.connect(hide)


func _on_master_changed(value: float):
	var linear_vol = value / 100.0
	AudioServer.set_bus_volume_db(0, linear_to_db(linear_vol))

func _on_sfx_changed(value: float):
	var linear_vol = value / 100.0
	var bus_idx = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(linear_vol))

func _on_bgm_changed(value: float):
	var linear_vol = value / 100.0
	var bus_idx = AudioServer.get_bus_index("BGM")
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(linear_vol))
