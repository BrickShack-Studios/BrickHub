extends Tabs

signal launchButtonPressed

var description = ""
var news = ""
var updateLink = ""

func initialize(d, n, u):
	description = d
	news = n
	updateLink = u
	
	refreshTab()
	return

func refreshTab():
	$MarginContainer/VBoxContainer/HBoxContainer/News.parse_bbcode(news)
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Description.parse_bbcode(description)
	return

func _on_Button_pressed():
	emit_signal("launchButtonPressed")
