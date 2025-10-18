@tool
extends Node

@export var settings: TGExportSettings

@export var title: LineEdit
@export var description: LineEdit
@export var icon: LineEdit
@export var image: LineEdit
@export var icon_fd: TGFileDialog
@export var image_fd: TGFileDialog
@export var discoverable: CheckBox


func _ready() -> void:
	set_initial()
	
	title.text_changed.connect(func(text): settings.title = text)
	description.text_changed.connect(func(text): settings.description = text)
	icon.text_changed.connect(func(text): settings.icon = text)
	icon_fd.file_selected.connect(func(path): settings.icon = path)
	image.text_changed.connect(func(text): settings.image = text)
	image_fd.file_selected.connect(func(path): settings.image = path)
	discoverable.toggled.connect(func(toggled_on): settings.discoverable = toggled_on)


func set_initial() -> void:
	title.text = settings.title
	description.text = settings.description
	icon.text = settings.icon
	image.text = settings.image
	discoverable.button_pressed = settings.discoverable
	
	title.text_changed.emit(title.text)
	description.text_changed.emit(description.text)
	icon.text_changed.emit(icon.text)
	image.text_changed.emit(image.text)
	discoverable.toggled.emit(settings.discoverable)
