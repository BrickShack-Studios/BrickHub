extends HTTPRequest

signal finishedUpdate

func start(link, downloadFile):
	download_file = downloadFile
	request(link)
	return
	
func _on_InitialUpdater_request_completed(result, response_code, headers, body):
	emit_signal("finishedUpdate", result)