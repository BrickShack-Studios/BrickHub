extends Control

onready var button = get_node("MarginContainer/CenterContainer/VBoxContainer/Button")
var logger = load("res://Scripts/Logger.gd").new()
var hasher = load("res://Scripts/Hasher.gd").new()
var jsonWrapper = load("res://Scripts/JSONParserWrapper.gd").new()


var launcherDirectory = null

func _ready():
	var args = OS.get_cmdline_args()
	
	for i in range(args.size()):
		if (args[i] == "--hasDir"):			
			launcherDirectory = args[i + 1].right(2) #cut off flag
			$MarginContainer/CenterContainer/VBoxContainer/Button.disabled = true
			$MarginContainer/CenterContainer/VBoxContainer/Label.hide()
			logger.logLine("Received argument: " + launcherDirectory)
			_on_Button_pressed()
			break
	return 

func _on_Button_pressed():
	logger.logLine("Beginning BrickHub update...")
	button.text = "Updating..."
	button.disabled = true
	
	if (launcherDirectory == null):
		logger.logLine("Prompting for launcher executable...")
		$FileDialog.popup_centered_minsize(Vector2(600,400))
	else:
		performUpdate()
	
	return

func performUpdate():
	logger.logLine("Copying files...")
	var dir = Directory.new()
	var thisDirectory = OS.get_executable_path().get_base_dir()
	
	dir.copy(thisDirectory +"/"+ "BrickHub.exe",
			launcherDirectory + "/" + "BrickHub.exe")
	dir.copy(thisDirectory + "/" + "BrickHub.pck",
			launcherDirectory + "/" + "BrickHub.pck")
	
	logger.logLine("Launching main launcher...")
	OS.execute(ProjectSettings.globalize_path(launcherDirectory + "/" + "BrickHub.exe"), [], false)
	get_tree().quit()
	return

func _on_FileDialog_file_selected(path):
	launcherDirectory = path.get_base_dir()
	performUpdate()
	return
