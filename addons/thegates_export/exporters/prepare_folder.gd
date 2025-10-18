@tool
class_name TGPrepareFolder
extends Node


func prepare(settings: TGExportSettings) -> void:
	if DirAccess.dir_exists_absolute(settings.export_folder): return
	DirAccess.make_dir_recursive_absolute(settings.export_folder)
	FileAccess.open(settings.export_folder.path_join(".gdignore"), FileAccess.WRITE).close()
