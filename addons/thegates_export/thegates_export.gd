@tool
extends EditorPlugin

const DOCK_TSCN = "res://addons/thegates_export/dock/dock.tscn"
const EXPORT_GD = "res://addons/thegates_export/exporters/export.gd"
const EXPORT_AUTOLOAD_NAME = "TGExport"

var dock: Control


func _enter_tree():
	dock = preload(DOCK_TSCN).instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)
	
	add_autoload_singleton(EXPORT_AUTOLOAD_NAME, EXPORT_GD)


func _exit_tree():
	remove_control_from_docks(dock)
	dock.free()
	
	remove_autoload_singleton(EXPORT_AUTOLOAD_NAME)
