@tool
extends Control

@export var settings: TGExportSettings
@export var export_button: Button
@export var published_url: TGPublishedUrl

var tgExport: TGExport


func _ready() -> void:
	tgExport = TGExport.new()
	add_child(tgExport)
	
	export_button.pressed.connect(export)
	check_project()


func export() -> void:
	var url = await tgExport.export_project(settings)
	update_url(url)


func check_project() -> void:
	var url = await tgExport.check_project(settings)
	update_url(url)


func update_url(url: String) -> void:
	published_url.set_url(url)
	export_button.text = "Publish to TheGates" if url.is_empty() else "Update project"
