@tool
extends EditorPlugin

const DOCK_TSCN = "res://addons/thegates_export/dock/dock.tscn"
const EXPORT_GD = "res://addons/thegates_export/exporters/export.gd"

var dock: Control


func _enter_tree():
	scene_saved.connect(on_scene_saved)
	add_dock()


func _exit_tree():
	if scene_saved.is_connected(on_scene_saved):
		scene_saved.disconnect(on_scene_saved)
	remove_dock()


func on_scene_saved(scene_path: String):
	if scene_path == DOCK_TSCN:
		remove_dock()
		add_dock()


func add_dock():
	dock = load(DOCK_TSCN).instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)


func remove_dock():
	if is_instance_valid(dock):
		remove_control_from_docks(dock)
		dock.free()
	
	dock = null
