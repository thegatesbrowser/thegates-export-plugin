@tool
extends Node

@export var settings: TGExportSettings

@export var title: LineEdit
@export var description: LineEdit
@export var image: LineEdit
@export var export_folder: LineEdit


func _ready() -> void:
	set_initial()
	
	title.text_changed.connect(func(text): settings.title = text)
	description.text_changed.connect(func(text): settings.description = text)
	image.text_changed.connect(func(text): settings.image = text)
	export_folder.text_changed.connect(func(text): settings.export_folder = text)


func set_initial() -> void:
	title.text = settings.title
	description.text = settings.description
	image.text = settings.image
	export_folder.text = settings.export_folder
	
	title.text_changed.emit()
	description.text_changed.emit()
	image.text_changed.emit()
	export_folder.text_changed.emit()
