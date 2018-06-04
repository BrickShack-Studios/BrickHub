extends HTTPRequest

onready var logger = load("res://Scripts/Logger.gd").new()

func download(link, downloadFile):
	logger.logLine("Downloading " + downloadFile + "...")
	
	download_file = downloadFile
	request(link)
	return