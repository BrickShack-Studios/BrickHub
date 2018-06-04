extends Node

var logger = load("res://Scripts/Logger.gd").new()

func parseJSON(path):
	logger.logLine("Parsing " + path + "...")
	var file = File.new()
	
	if (!file.file_exists(path)):
		logger.logLine("Error: " + path + " does not exist!")
	else:
		file.open(path, File.READ)
		var contents = file.get_as_text()
		file.close()
		
		var parsed = JSON.parse(contents)
		
		if (parsed.error != 0):
			logger.logLine("Error parsing " + path + "! Details:")
			logger.logLine(parsed.error)
			logger.logLine(parsed.error_line)
			logger.logLine(parsed.error_string)
		else:
			logger.logLine("Successfully parsed " + path)
			return parsed.result
	
	return null