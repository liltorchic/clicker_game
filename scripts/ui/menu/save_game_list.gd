extends VBoxContainer

@onready var save_entry_template =  preload("res://scenes/save_game.tscn")
@onready var back_button:Button = $Button

func _ready() -> void:	
	load_list()	

#gets called by a signal when a save file is deleted
func load_list():
	
	# remove all children from list to account for possible save file deletion
	var children = get_children()
	for child in children:
		if child is not Button:
			child.queue_free()
	
	if DirAccess.dir_exists_absolute(Constants.SAVE_PATH):
			var files = DirAccess.get_files_at(Constants.SAVE_PATH)
			
			#for every save file, add a save entry to the tree and update its internal index 
			# to correspond to the save file
			for file in files:
				var save_entry:SaveEntry = save_entry_template.instantiate()
				add_child(save_entry)
				save_entry.set_index(file)
				save_entry.deleted_save.connect(load_list)
	else:
		printerr("Directory does not exist: ", Constants.SAVE_PATH)
	
	# move back button to the bottom
	move_child(back_button, get_child_count())
