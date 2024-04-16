@tool
extends Button

@export var pack_path: LineEdit
@export var pack_name: String

var preset_creator: TGPresetCreator
var pid: int = -1


func _ready() -> void:
	button_up.connect(export_pack)
	preset_creator = TGPresetCreator.new()


func export_pack() -> void:
	if OS.is_process_running(pid):
		print("Export is still in progress, please wait")
		return
	print("\n=================== Starting export ===================")
	
	var path = pack_path.text + "/" + pack_name
	var preset_name = preset_creator.create_and_get_preset()
	var args = ["--headless", "--export-pack", preset_name, path]
	
	print("Execute godot: ", args)
	pid = OS.create_instance(args)


func check_status() -> void:
	print("Export is in progress...")
	if OS.is_process_running(pid): return
	
	pid = -1
	print("Export is done")
