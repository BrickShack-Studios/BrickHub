extends Object

var logger = load("res://Scripts/Logger.gd").new()
var linksFile = ""

onready var Hasher = load("res://Scripts/Hasher.gd").new()
onready var jsonWrapper = load("res://Scripts/JSONParserWrapper.gd").new()

var jsonTripFlag = false

func checkIfAuxillary():
	var dir = Directory.new()
	var isAuxillary = false
	if (dir.file_exists(OS.get_executable_path().get_base_dir() + "/u")):
		isAuxillary = true

	var args = OS.get_cmdline_args()
	for arg in args:
		if (arg == "--hasDir"):
			isAuxillary = true
	
	if (isAuxillary):
		get_tree().change_scene("res://Scenes/Launcher Updater.tscn")
	
	return

func _ready():
	checkIfAuxillary()
	
	if (jsonTripFlag == true):
		logger.logLine("Error: a JSON file was previously corrupted and not gracefully handled")
	
	$TabContainer/BrickHub/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Button.hide()
	logger.logLine("Attempting to download database...")
	var file = File.new()
	var jsonPath = "res://Defaults/database.json"
	
	if (file.file_exists("user://database.json")):
		jsonPath = "user://database.json"
	else:
		logger.logLine("Fresh install detected")
	
	var json = jsonWrapper.parseJSON(jsonPath)
	$InitialUpdater.start(json.brickHub.databaseLink, "user://database.tmp")
	
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
		
		#try parsing it to check for errors
		var tmp = jsonWrapper.parseJSON("user://database.tmp")
		
		if (file.get_len() > 0 && !jsonTripFlag):
			logger.logLine("Database downloaded successfully")
			file.close()
			
			var dir = Directory.new()
			dir.open("user://")
			if (file.file_exists("user://database.json")):
				dir.remove("database.json")
			dir.rename("database.tmp", "database.json")
		else:
			logger.logLine("Warning: the database was not successfully downloaded. While an old cache will be used, this may be out of date. Check your internet connection.")
			file.close()
	
	logger.logLine("Done updating database")
	
	loadTabs()
	return
	
func loadTabs():
	logger.logLine("Initializing tabs...")
	var database = jsonWrapper.parseJSON("user://database.json")
	
	$TabContainer/BrickHub.initialize(	database.brickHub.description,
										database.brickHub.news,
										"",
										OS.get_executable_path().get_base_dir(),
										database.brickHub.executable)
	
	for element in database.games:
		if (element.name == "BrickHub Update"):
			var scene = load("res://Objects/AuxillaryUpdater.tscn")
			var sceneInstance = scene.instance()
			sceneInstance.set_name(element.name)
			add_child(sceneInstance)
			sceneInstance.initialize(	element.downloadLink,
										element.gameDir,
										element.executable)
		else:
			var scene = load("res://Objects/GameTab.tscn")
			var sceneInstance = scene.instance()
			sceneInstance.set_name(element.name)
			$TabContainer.add_child(sceneInstance)
			sceneInstance.initialize(	element.description,
										element.news,
										element.downloadLink,
										element.gameDir,
										element.executable)
	
	logger.logLine("Tabs initialized")
	
	return