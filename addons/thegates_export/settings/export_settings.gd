@tool
class_name TGExportSettings
extends Resource

@export var title: String
@export var description: String
@export var icon: String
@export var image: String
@export var export_folder: String

const PACK_NAME = "project.zip"
const ICON_NAME = "icon.%s"
const IMAGE_NAME = "image.%s"
const GATE_NAME = "project.gate"

var pack_path: String : get = get_pack_path
var icon_path: String : get = get_icon_path
var image_path: String : get = get_image_path
var gate_path: String : get = get_gate_path

var supported_versions: = ["4.3", "4.5"]
var supported_rendering_methods: = ["forward_plus"]


func get_pack_path() -> String:
	return export_folder + "/" + PACK_NAME


func get_icon_path() -> String:
	if icon.is_empty(): return ""
	
	var ext = icon.get_extension()
	return export_folder + "/" + ICON_NAME % [ext]


func get_image_path() -> String:
	if image.is_empty(): return ""
	
	var ext = image.get_extension()
	return export_folder + "/" + IMAGE_NAME % [ext]


func get_gate_path() -> String:
	return export_folder + "/" + GATE_NAME


func get_godot_version() -> String:
	var version_info = Engine.get_version_info()
	var major = version_info["major"]
	var minor = version_info["minor"]
	return str(major) + "." + str(minor)


func get_supported_versions() -> Array:
	return supported_versions


func get_rendering_method() -> String:
	return ProjectSettings.get_setting("rendering/renderer/rendering_method")


func get_supported_rendering_methods() -> Array:
	return supported_rendering_methods
