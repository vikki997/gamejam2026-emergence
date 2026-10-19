extends TextureButton

# 把你的SettingsPopup弹窗节点拖进这个导出变量
@export var VolumeSettingPopup: PopupPanel

func _ready():
	pressed.connect(_open_settings)

func _open_settings():
	VolumeSettingPopup.popup_centered() # 在屏幕正中间弹出窗口
