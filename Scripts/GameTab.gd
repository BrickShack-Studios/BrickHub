extends Tabs

signal launchButtonPressed

onready var buttonNode = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Button

var hasher = load("res://Scripts/Hasher.gd").new()
var logger = load("res://Scripts/Logger.gd").new()
var jsonWrapper = load("res://Scripts/JSONParserWrapper.gd").new()

var description = ""
var news = ""
var updateLink = ""
var gameDirectory = ""
var executable = ""

var updateFile = ""

var downloadQueue = []
var downloadingUpdates = false

func initialize(d, n, u, g, e):
	description = d
	news = n
	updateLink = u
	gameDirectory = g
	executable = e
	
	updateFile = gameDirectory + "/updates.json"
	$Downloader.attachButton(buttonNode)
	
	var dir = Directory.new()
	if (!dir.dir_exists(gameDirectory)):
		dir.make_dir_recursive(gameDirectory)
	
	refreshTab()
	return

func refreshTab():
	$MarginContainer/VBoxContainer/HBoxContainer/News.parse_bbcode(news)
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Description.parse_bbcode(description)
	downloadingUpdates = false
	
	var file = File.new()
	if (file.file_exists(gameDirectory + "/" + executable)):
		buttonNode.text = "Check for Updates"
	else:
		buttonNode.text = "Install"
	return

func _on_Button_pressed():
	if (buttonNode.text == "Launch"):
		OS.execute(ProjectSettings.globalize_path(gameDirectory + "/" + executable), [], false)
		refreshTab()
	else:
		buttonNode.disabled = true
		downloadUpdates()
	
	return
	
func downloadUpdates():
	$Downloader.download(updateLink, updateFile)
	$MarginContainer/VBoxContainer/ProgressBar.show()
	print("Shown!")
	return
	
func checkForUpdates():
	var localHashTable = hasher.hashDir(gameDirectory)
	var update = jsonWrapper.parseJSON(updateFile)
	
	var file = File.new()
	for item in update.files:
		if (!file.file_exists(item.path) ||
				localHashTable[item.path] == null ||
				localHashTable[item.path] != item.md5):
			
			buttonNode.text = logger.logLine("Found update for " + item.path)
			downloadQueue.push_front(item.link)
			downloadQueue.push_front(item.path)
	
	# Will automatically update the rest
	if (downloadQueue.size() > 0):
		$Downloader.download(downloadQueue.pop_back(), downloadQueue.pop_back())
	else:
		logger.logLine("No updates found")
		buttonNode.text = "Launch"
		buttonNode.disabled = false
		$MarginContainer/VBoxContainer/ProgressBar.hide()
	return

func _on_Downloader_request_completed(result, response_code, headers, body):
	if (downloadingUpdates):
		if (downloadQueue.size() == 0):
			logger.logLine("Finished update")
			buttonNode.text = "Launch"
			buttonNode.disabled = false
			$MarginContainer/VBoxContainer/ProgressBar.hide()
		else:
			$Downloader.download(downloadQueue.pop_back(), downloadQueue.pop_back())
	else:
		downloadingUpdates = true
		checkForUpdates()
	return

func _on_Downloader_updateProgressBar(percent):
	$MarginContainer/VBoxContainer/ProgressBar.value = percent
	return
