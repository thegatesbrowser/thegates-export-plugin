@tool
class_name TGProjectPublisher
extends Node

const DEFAULT_API_BASE_URL = "https://app.thegates.io"
const PUBLISH_API_PATH = "/api/publish_project"
const GET_PUBLISHED_API_PATH = "/api/get_published_project"

const FORM_FIELD_USER_ID = "user_id"
const FORM_FIELD_PROJECT_NAME = "project_name"
const FORM_FIELD_FILES = "files"

const DEFAULT_USER_ID = "test_user"


func get_publish_endpoint() -> String:
	return "%s%s" % [get_api_base_url(), PUBLISH_API_PATH]


func get_check_endpoint() -> String:
	return "%s%s" % [get_api_base_url(), GET_PUBLISHED_API_PATH]


func get_api_base_url() -> String:
	if OS.has_feature("web"):
		var base_url = JavaScriptBridge.eval("window.location.protocol + '//' + window.location.host")
		return str(base_url)
	
	return DEFAULT_API_BASE_URL


func get_user_id() -> String:
	if OS.has_feature("web"):
		var user_id := JavaScriptBridge.eval("window.getTheGatesUserId()")
		return str(user_id)
	
	return DEFAULT_USER_ID


func publish(settings: TGExportSettings) -> String:
	if not is_valid(settings):
		return ""
	
	var file_payloads: Array = []
	
	var gate_payload := build_file_payload(settings.get_gate_path())
	if not gate_payload.is_empty(): file_payloads.append(gate_payload)
	
	var pack_payload := build_file_payload(settings.get_pack_path())
	if not pack_payload.is_empty(): file_payloads.append(pack_payload)
	
	var icon_payload := build_file_payload(settings.get_icon_path())
	if not icon_payload.is_empty(): file_payloads.append(icon_payload)
	
	var image_payload := build_file_payload(settings.get_image_path())
	if not image_payload.is_empty(): file_payloads.append(image_payload)
	
	if file_payloads.is_empty():
		printerr("Publishing aborted: no export artifacts found")
		return ""
	
	var form_data := {
		FORM_FIELD_USER_ID: get_user_id(),
		FORM_FIELD_PROJECT_NAME: ProjectSettings.get_setting("application/config/name"),
	}
	
	var boundary := "----TheGatesBoundary%d" % Time.get_ticks_usec()
	var body := build_multipart_body(boundary, form_data, file_payloads)
	var headers := PackedStringArray([
		"Content-Type: multipart/form-data; boundary=%s" % boundary,
		"Accept: application/json"
	])
	
	# var token := settings.get_publish_token()
	# if not token.is_empty():
	# 	headers.append("Authorization: Bearer %s" % token)
	
	var request := HTTPRequest.new()
	add_child(request)
	
	var error := request.request_raw(get_publish_endpoint(), headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		printerr("Publish request failed to start: %s" % error)
		request.queue_free()
		return ""
	
	var completed = await request.request_completed
	request.queue_free()
	
	var result: int = completed[0]
	var response_code: int = completed[1]
	var _headers: PackedStringArray = completed[2]
	var response_body: PackedByteArray = completed[3]
	
	if result != HTTPRequest.RESULT_SUCCESS:
		printerr("Publish request failed: result=%s" % result)
		return ""
	
	return process_publish_response(result, response_code, response_body)


func is_valid(settings: TGExportSettings) -> bool:
	if not FileAccess.file_exists(settings.get_pack_path()):
		printerr("Missing exported pack: %s" % settings.get_pack_path())
		return false
	
	if not FileAccess.file_exists(settings.get_gate_path()):
		printerr("Missing gate metadata: %s" % settings.get_gate_path())
		return false
	
	return true


func build_file_payload(path: String) -> Dictionary:
	if path.is_empty():
		return {}
	
	if not FileAccess.file_exists(path):
		return {}
	
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		printerr("Failed to open file for publishing: %s" % path)
		return {}
	
	var data := file.get_buffer(file.get_length())
	file.close()
	
	return {
		"name": FORM_FIELD_FILES,
		"filename": path.get_file(),
		"body": data,
		"content_type": guess_mime_type(path.get_file())
	}


func build_multipart_body(boundary: String, form: Dictionary, files: Array) -> PackedByteArray:
	var body := PackedByteArray()
	
	for key in form.keys():
		var value = form[key]
		if value == null:
			continue
		body.append_array(form_field_segment(boundary, key, str(value)))
	
	for file_dict in files:
		body.append_array(file_field_segment(boundary, file_dict))
	
	body.append_array(multipart_closing(boundary))
	return body


func form_field_segment(boundary: String, key: String, value: String) -> PackedByteArray:
	var segment = "--%s\r\nContent-Disposition: form-data; name=\"%s\"\r\n\r\n%s\r\n" % [boundary, key, value]
	return segment.to_utf8_buffer()


func file_field_segment(boundary: String, file_dict: Dictionary) -> PackedByteArray:
	var filename: String = file_dict.get("filename", "file")
	var name: String = file_dict.get("name", FORM_FIELD_FILES)
	var data: PackedByteArray = file_dict.get("body", PackedByteArray())
	var content_type: String = file_dict.get("content_type", "application/octet-stream")
	
	var header = "--%s\r\nContent-Disposition: form-data; name=\"%s\"; filename=\"%s\"\r\nContent-Type: %s\r\n\r\n" % [boundary, name, filename, content_type]
	var footer = "\r\n"
	
	var segment := PackedByteArray()
	segment.append_array(header.to_utf8_buffer())
	segment.append_array(data)
	segment.append_array(footer.to_utf8_buffer())
	return segment


func multipart_closing(boundary: String) -> PackedByteArray:
	return ("--%s--\r\n" % boundary).to_utf8_buffer()


func guess_mime_type(filename: String) -> String:
	var extension := filename.get_extension().to_lower()
	match extension:
		"png":
			return "image/png"
		"jpg", "jpeg":
			return "image/jpeg"
		"webp":
			return "image/webp"
		"bmp":
			return "image/bmp"
		"svg":
			return "image/svg+xml"
		"zip":
			return "application/zip"
		"gate":
			return "application/octet-stream"
		_:
			return "application/octet-stream"


func process_publish_response(result: int, response_code: int, body: PackedByteArray) -> String:
	print("Publish completed: result=%s, http=%s" % [result, response_code])
	var text := body.get_string_from_utf8()
	if text.is_empty():
		return ""
	
	var json := JSON.new()
	var parse_error := json.parse(text)
	if parse_error == OK:
		var data = json.data
		if typeof(data) == TYPE_DICTIONARY:
			var response: Dictionary = data
			if response.has("url"):
				var url_value := str(response["url"]) if typeof(response["url"]) == TYPE_STRING else ""
				if not url_value.is_empty():
					return url_value
			# Fallthrough: print body for diagnostics if structure unexpected
			print(text)
	else:
		printerr("Failed to parse publish response: %s" % json.get_error_message())
		printerr(text)
	
	if response_code != 201:
		printerr("Publishing failed with HTTP status %s" % response_code)
	
	return ""


func check_project() -> String:
	var project_name := str(ProjectSettings.get_setting("application/config/name"))
	var query_parts := PackedStringArray([
		"%s=%s" % [FORM_FIELD_USER_ID, get_user_id().uri_encode()],
		"%s=%s" % [FORM_FIELD_PROJECT_NAME, project_name.uri_encode()]
	])
	var request_url := "%s?%s" % [get_check_endpoint(), "&".join(query_parts)]
	var headers := PackedStringArray(["Accept: application/json"])
	
	var request := HTTPRequest.new()
	add_child(request)
	
	var error := request.request(request_url, headers, HTTPClient.METHOD_GET)
	if error != OK:
		printerr("Check project request failed to start: %s" % error)
		request.queue_free()
		return ""
	
	var completed = await request.request_completed
	request.queue_free()
	
	var result: int = completed[0]
	var response_code: int = completed[1]
	var _headers: PackedStringArray = completed[2]
	var body: PackedByteArray = completed[3]
	
	if result != HTTPRequest.RESULT_SUCCESS:
		printerr("Check project request failed: result=%s" % result)
		return ""
	
	if response_code == 404:
		return ""
	
	if response_code != 200:
		printerr("Check project request returned HTTP %s" % response_code)
		return ""
	
	var text := body.get_string_from_utf8()
	if text.is_empty():
		return ""
	
	var json := JSON.new()
	var parse_error := json.parse(text)
	if parse_error != OK:
		printerr("Failed to parse check project response: %s" % json.get_error_message())
		printerr(text)
		return ""
	
	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		return ""
	
	var response: Dictionary = data
	if response.get("status", "") != "ok":
		return ""
	
	if response.get("code", "") != "published":
		return ""
	
	var url := response.get("url", "")
	if typeof(url) == TYPE_STRING:
		return url
	
	return ""
