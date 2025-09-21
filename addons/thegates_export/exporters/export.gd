@tool
class_name TGExport
extends Node

var pack_exporter: TGPackExporter
var icon_exporter: TGIconExporter
var image_exporter: TGImageExporter
var gate_exporter: TGGateExporter


func _ready() -> void:
	pack_exporter = TGPackExporter.new()
	icon_exporter = TGIconExporter.new()
	image_exporter = TGImageExporter.new()
	gate_exporter = TGGateExporter.new()
	
	add_child(pack_exporter)
	add_child(icon_exporter)
	add_child(image_exporter)
	add_child(gate_exporter)


func export_project(settings: TGExportSettings) -> void:
	if pack_exporter.is_in_progress():
		print("Export is still in progress, please wait")
		return
	
	if settings.get_godot_version() not in settings.get_supported_versions():
		printerr("Unsupported Godot version: %s. Please use Godot 4.3 or 4.5 (recommended)." % [settings.get_godot_version()])
		return
	
	if settings.get_rendering_method() not in settings.get_supported_rendering_methods():
		printerr("Unsupported rendering method: %s. Please use Forward+." % [settings.get_rendering_method()])
		return
	
	print("\n=================== Starting export ===================")
	pack_exporter.export(settings)
	icon_exporter.export(settings)
	image_exporter.export(settings)
	gate_exporter.export(settings)
