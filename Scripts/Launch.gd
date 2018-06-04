extends Object

var parser = XMLParser.new()
var linksFile = ""

onready var Hasher = load("res://Scripts/Hasher.gd").new()

func parseJSON(path):
	var file = File.new()
	
	if (!file.file_exists(path)):
		print("Error: " + path + " does not exist!")
	else:
		file.open(path, File.READ)
		var contents = file.get_as_text()
		file.close()
		
		var parsed = JSON.parse(contents)
		
		if (parsed.error != 0):
			print("Error parsing " + path + "! Details:")
			print(parsed.error)
			print(parsed.error_line)
			print(parsed.error_string)
		else:
			return parsed.result
	
	return null

func _ready():
	var file = File.new()
	var jsonPath = "res://Defaults/database.json"
	
	if (file.file_exists("user://database.json")):
		print("Database exists")
		jsonPath = "user://database.json"
	
	var json = parseJSON(jsonPath)
	$InitialUpdater.start(json.brickHub.databaseLink, "user://database.tmp")
	
	return

func start():
	var test = Hasher.hashDir("user://Test")
	
	for item in test.keys():
		print(str(item) + "\t:\t" + str(test[item]))

	return

func _on_InitialUpdater_finishedUpdate(response):
	if (response != 0):
		print("Error grabbing initial update. While the old caches will work, note that BrickHub may be out of date. Check your internet connection.")
		var file = File.new()
		if (!file.file_exists("user://database.json")):
			var dir = Directory.new()
			dir.open("res://Defaults")
			dir.copy("database.json", "user://database.json")
	else:
		var file = File.new()
		file.open("user://database.tmp", File.READ)
		if (file.get_len() > 0):
			file.close()
			
			var dir = Directory.new()
			dir.open("user://")
			if (file.file_exists("user://database.json")):
				dir.remove("database.json")
			dir.rename("database.tmp", "database.json")
		else:
			file.close()
	
	print("Updated database")
	
	loadTabs()
	return
	
func loadTabs():
	var database = parseJSON("user://database.json")
	
	print("Initializing tabs...")
	for element in database.games:
		var scene = load("res://Objects/GameTab.tscn")
		var sceneInstance = scene.instance()
		sceneInstance.set_name(element.name)
		sceneInstance.initialize(	element.description,
									element.news,
									element.downloadLink)
		$TabContainer.add_child(sceneInstance)
	print("Tabs initialized")
	
	return