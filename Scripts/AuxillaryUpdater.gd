extends Node2D

var hasher = load("res://Scripts/Hasher.gd").new()
var logger = load("res://Scripts/Logger.gd").new()
var jsonWrapper = load("res://Scripts/JSONParserWrapper.gd").new()

var downloadQueue = []

var updateLink = ""
var gameDirectory = ""
var executable = ""

var updateFile = ""

var downloadingUpdates = false

func initialize(u, g, e):
	updateLink = u
	gameDirectory = g
	executable = e
	
	updateFile = gameDirectory + "/updates.json"
	
	var dir = Directory.new()
	if (!dir.dir_exists(gameDirectory)):
		dir.make_dir_recursive(gameDirectory)
	
	downloadUpdates()
	return
	
func downloadUpdates():
	$Downloader.download(updateLink, updateFile)
	return
	
func checkForUpdates():
	var localHashTable = hasher.hashDir(gameDirectory)
	var update = jsonWrapper.parseJSON(updateFile)
	
	var file = File.new()
	for item in update.files:
		if (!file.file_exists(item.path) ||
				localHashTable[item.path] == null ||
				localHashTable[item.path] != item.md5):
			
			logger.logLine("Found launcher update for " + item.path)
			downloadQueue.push_front(item.link)
			downloadQueue.push_front(item.path)
	
	if (downloadQueue.size() > 0):
		$Confirm.popup_centered()
		logger.logLine("Prompted launcher update...")
	else:
		logger.logLine("Launcher up-to-date")
		
	return
	
func launchUpdate():
	#flagged so Godot doesn't cry
	var thisDir = "--" + OS.get_executable_path().get_base_dir()
	logger.logLine("Recognized current directory as " + thisDir)
	
	logger.logLine("Launching auxillary updater...")
	OS.execute(ProjectSettings.globalize_path(gameDirectory + "/" + executable), ["--hasDir", thisDir], false)
	
	get_tree().quit()
	return #

func _on_Downloader_request_completed(result, response_code, headers, body):
	if (downloadingUpdates):
		if (downloadQueue.size() == 0):
			logger.logLine("Downloaded launcher update")
			launchUpdate()
		else:
			$Downloader.download(downloadQueue.pop_back(), downloadQueue.pop_back())
	else:
		downloadingUpdates = true
		checkForUpdates()
	return

func _on_Confirm_confirmed():
	get_parent().get_node("TabContainer").hide()
	$Downloader.download(downloadQueue.pop_back(), downloadQueue.pop_back())
