@tool
extends Button

@export var pack_path: LineEdit

var pid: int = -1


func _ready() -> void:
	button_up.connect(export_pack)


func export_pack() -> void:
	if OS.is_process_running(pid): return
	
	var path = ""
	var args = ["--headless", "--export-pack", "Linux/X11", path]
	pid = OS.create_instance(args)
