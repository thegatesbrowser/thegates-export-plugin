@tool
extends Button

@export var pack_path: LineEdit
@export var pack_name: String

var timer: Timer
var preset_creator: TGPresetCreator
var pid: int = -1


func _ready() -> void:
	preset_creator = TGPresetCreator.new()
	
	timer = Timer.new()
	timer.one_shot = false
	add_child(timer)
	
	timer.timeout.connect(check_status)
	button_up.connect(export_pack)


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
	
	print("Exporting...")
	start_checking_status()


func start_checking_status() -> void:
	timer.start(2)
	check_status()


func check_status() -> void:
	if OS.is_process_running(pid): return
	
	pid = -1
	timer.stop()
	print("Done!")
