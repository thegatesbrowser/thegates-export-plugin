@tool
extends Button

@export var settings: TGExportSettings


func _ready() -> void:
	button_up.connect(export)


func export() -> void:
	TGExport.export_project(settings)
