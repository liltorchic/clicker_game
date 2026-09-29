extends MarginContainer
class_name SaveEntry

@onready var save_title_label:Label = $HBoxContainer/VBoxContainer/HBoxContainer_save_title/Label_save_data
@onready var save_score_label:Label = $HBoxContainer/VBoxContainer/HBoxContainer_save_stat_points/Label_save_stat_points_data

var filename:String

signal deleted_save

func set_index(_filename:String):
	filename = _filename
	
	# open corresponding save file
	var savegame_file = Constants.SAVE_PATH + _filename
	var file := FileAccess.open(savegame_file, FileAccess.READ)
	
	#if no save file exists on disk
	if(file == null):
		return
	
	# read save data
	var json := JSON.new()
	json.parse(file.get_line())
	var save_dict := json.get_data() as Dictionary
	
	#update save file labels
	save_title_label.text = save_dict.stats.game_save_index
	save_score_label.text = save_dict.stats.time_points
	
# load save button signal endpoint
func _on_button_pressed() -> void:
	Game.is_new_game = false
	Game.game_save_index = int(filename.replace("save_game_", "").replace(".json", ""))
	get_tree().change_scene_to_file("res://scenes/main.tscn")

# delete save button signal endpoint
func _on_button_delete_pressed() -> void:
	DirAccess.remove_absolute(Constants.SAVE_PATH + filename)
	# send deleted signal so parent can dynamically reload the save list
	deleted_save.emit()
