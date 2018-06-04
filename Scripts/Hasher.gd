extends Node

func crawl(directoryPath):
	var files = []
	var crawler = Directory.new()
	
	if (!crawler.dir_exists(directoryPath)):
		crawler.make_dir_recursive(directoryPath)
	
	if (crawler.open(directoryPath) == OK):
		crawler.list_dir_begin(true, true)
		
		var itemName = crawler.get_next()
		while (itemName != ""):
			if (!crawler.current_is_dir()):
				files.append(directoryPath + "/" + itemName)
			else:
				var recurse = crawl(directoryPath + "/" + itemName)
				for item in recurse:
					files.append(item)
			itemName = crawler.get_next()
			
		crawler.list_dir_end()
	else: #TODO: Log this
		print("Error opening directory: " + directoryPath)
		
	return files
	
func hashFiles(fileDirList):
	var hashTable = {}
	var fileHandler = File.new()
	#It would be a good idea to have error checking here
	#File opening can fail, and perhaps hashing can, too
	for path in fileDirList:
		hashTable[path] = fileHandler.get_md5(path)
	
	return hashTable
	
func hashDir(dirToHash):
	return hashFiles(crawl(dirToHash))