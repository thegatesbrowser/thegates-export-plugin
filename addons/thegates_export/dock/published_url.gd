@tool
extends Control
class_name TGPublishedUrl

@export var url_line_edit: LineEdit
@export var copy_button: Button


func _ready() -> void:
	visible = false
	url_line_edit.text = ""
	copy_button.pressed.connect(copy)

	var copy_icon = EditorInterface.get_base_control().get_theme_icon(&"ActionCopy", &"EditorIcons")
	copy_button.add_theme_icon_override("icon", copy_icon)


func set_url(url: String) -> void:
	visible = not url.is_empty()
	url_line_edit.text = url


func copy() -> void:
	DisplayServer.clipboard_set(url_line_edit.text)
