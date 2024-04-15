@tool
extends EditorPlugin

const dock_tscn = "res://addons/thegates_export/dock/dock.tscn"

var dock: Control


func _enter_tree():
	dock = preload(dock_tscn).instantiate()
	add_control_to_dock(DOCK_SLOT_LEFT_UR, dock)


func _exit_tree():
	remove_control_from_docks(dock)
	dock.free()
