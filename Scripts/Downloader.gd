extends HTTPRequest

var logger = load("res://Scripts/Logger.gd").new()

func download(link, downloadFile):
	var dir = Directory.new()
	if (!dir.dir_exists(downloadFile.get_base_dir())):
		dir.make_dir_recursive(downloadFile.get_base_dir())
	
	logger.logLine("Downloading " + downloadFile)
	
	download_file = downloadFile
	request(link)
	return