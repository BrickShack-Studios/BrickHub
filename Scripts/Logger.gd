extends Node

func _init():
	var file = File.new()
	if (!file.file_exists("user://log.txt")):
		file.open("user://log.txt", File.WRITE)
		file.close()
	
	return

func getDateTimeString():
	#Returns current datetime as a dictionary of keys:
	#	 year, month, day, weekday, dst (daylight savings time), 
	#	hour, minute, second.
	var dt = OS.get_datetime()
	return str(dt.year) + "-" + str(dt.month) + "-" + str(dt.day) + " " + str(dt.hour) + ":" + str(dt.minute) + ":" + str(dt.second)

func logLine(line, silent = false):
	if (!silent):
		print(line)
	
	var file = File.new()
	file.open("user://log.txt", File.READ_WRITE)
	
	file.seek_end()
	file.store_string(getDateTimeString() + "\t\t" + line + "\n")
	
	file.close()
	
	return line