extends Object

var logger = load("res://Scripts/Logger.gd").new()
var linksFile = ""

onready var Hasher = load("res://Scripts/Hasher.gd").new()

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

func _ready():
	logger.logLine("Attempting to download database...")
	var file = File.new()
	var jsonPath = "res://Defaults/database.json"
	
	if (file.file_exists("user://database.json")):
		jsonPath = "user://database.json"
	else:
		logger.logLine("Fresh install detected")
	
	var json = parseJSON(jsonPath)
	$InitialUpdater.start(json.brickHub.databaseLink, "user://database.tmp")
	
	return

func start():
	var test = Hasher.hashDir("user://Test")
	
	for item in test.keys():
		print(str(item) + "\t:\t" + str(test[item]))

	return

func _on_InitialUpdater_finishedUpdate(response):
	logger.logLine("Updating database...")
	if (response != 0):
		logger.logLine("Error grabbing initial update. While the old caches will work, note that BrickHub may be out of date. Check your internet connection.")
		var file = File.new()
		if (!file.file_exists("user://database.json")):
			var dir = Directory.new()
			dir.open("res://Defaults")
			dir.copy("database.json", "user://database.json")
	else:
		var file = File.new()
		file.open("user://database.tmp", File.READ)
		if (file.get_len() > 0):
			logger.logLine("Database downloaded successfully")
			file.close()
			
			var dir = Directory.new()
			dir.open("user://")
			if (file.file_exists("user://database.json")):
				dir.remove("database.json")
			dir.rename("database.tmp", "database.json")
		else:
			file.close()
	
	logger.logLine("Updated database")
	
	loadTabs()
	return
	
func loadTabs():
	logger.logLine("Initializing tabs...")
	var database = parseJSON("user://database.json")
	
	$TabContainer/BrickHub.initialize(	database.brickHub.description,
										database.brickHub.news,
										"")
	for element in database.games:
		var scene = load("res://Objects/GameTab.tscn")
		var sceneInstance = scene.instance()
		sceneInstance.set_name(element.name)
		sceneInstance.initialize(	element.description,
									element.news,
									element.downloadLink)
		$TabContainer.add_child(sceneInstance)
	logger.logLine("Tabs initialized")
	
	return