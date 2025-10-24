@tool
class_name TGExportSettings
extends Resource

signal advanced_settings_changed(enabled: bool)
signal export_locally_changed(enabled: bool)

@export var title: String
@export var description: String
@export var icon: String
@export var image: String
@export var discoverable: bool

@export var advanced_settings: bool: set = set_advanced_settings
@export var export_locally: bool: set = set_export_locally

const PACK_NAME = "project.zip"
const ICON_NAME = "icon.%s"
const IMAGE_NAME = "image.%s"
const GATE_NAME = "project.gate"
const TOKEN_NAME = "publish.key"

var export_folder: String = ProjectSettings.globalize_path("res://addons/thegates_export/export")

var pack_path: String : get = get_pack_path
var icon_path: String : get = get_icon_path
var image_path: String : get = get_image_path
var gate_path: String : get = get_gate_path
var token_path: String : get = get_token_path

var supported_versions: = ["4.3", "4.5"]
var supported_rendering_methods: = ["forward_plus"]

var published_url: String


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


func get_token_path() -> String:
	return export_folder + "/" + TOKEN_NAME


func get_godot_version() -> String:
	var version_info = Engine.get_version_info()
	var major = version_info["major"]
	var minor = version_info["minor"]
	return str(major) + "." + str(minor)


func get_rendering_method() -> String:
	return ProjectSettings.get_setting("rendering/renderer/rendering_method")


func set_advanced_settings(value: bool) -> void:
	advanced_settings = value
	advanced_settings_changed.emit(value)


func set_export_locally(value: bool) -> void:
	export_locally = value
	export_locally_changed.emit(value)
