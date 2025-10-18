@tool
extends RichTextLabel

@export var description: LineEdit


func _ready() -> void:
	description.text_changed.connect(set_text)
	set_text(description.text)


func set_text(_text: String) -> void:
	text = _text if not _text.is_empty() else "[color=DIM_GRAY][i]Description preview with BBCode[/i][/color]"
