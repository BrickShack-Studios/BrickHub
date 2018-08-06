extends HTTPRequest

var logger = load("res://Scripts/Logger.gd").new()

var buttonHook = null
var percent = 0

signal updateProgressBar

func attachButton(button):
	buttonHook = button
	return

func download(link, downloadFile):
	var dir = Directory.new()
	if (!dir.dir_exists(downloadFile.get_base_dir())):
		dir.make_dir_recursive(downloadFile.get_base_dir())
	
	if (buttonHook != null):
		buttonHook.text = logger.logLine("Downloading " + downloadFile)
	else:
		logger.logLine("Downloading " + downloadFile)
	
	download_file = downloadFile
	request(link)
	$UpdateTimer.start()
	return

func _on_UpdateTimer_timeout():
	var p = float(get_downloaded_bytes()) / get_body_size() * 100
	if (p != percent):
		percent = p
		emit_signal("updateProgressBar", percent)
	if (percent == 100):
		p = 0
	else:
		$UpdateTimer.start()
	return