@tool
class_name TGImageExporter
extends Node


func export(settings: TGExportSettings) -> void:
	var path = settings.get_image_path()
	DirAccess.copy_absolute(settings.image, path)
