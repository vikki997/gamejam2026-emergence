extends Area2D

@onready var notebook_popup: PopupPanel = $"../NotebookPopup"

func _input_event(viewport, event, shape_idx):
	if event.is_action_pressed("interact"):
		notebook_popup.popup_centered()
