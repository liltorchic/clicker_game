extends Control


@onready var window_options: OptionButton = $settings/OptionButton
@onready var slider_music : HSlider = $settings/HBoxContainer_Music/HSlider
@onready var slider_clicks : HSlider = $settings/HBoxContainer_Clicks/HSlider
@onready var slider_amb : HSlider = $settings/HBoxContainer_Amb/HSlider
@onready var slider_sfx : HSlider = $settings/HBoxContainer_SFX/HSlider
@onready var slider_alarm : HSlider = $settings/HBoxContainer_Alarm/HSlider

#initalize audio bus'
var audio_music_bus = AudioServer.get_bus_index("Music")
var audio_click_bus = AudioServer.get_bus_index("Clicks")
var audio_amb_bus = AudioServer.get_bus_index("AMB")
var audio_sfx_bus = AudioServer.get_bus_index("SFX")
var audio_alarm_bus = AudioServer.get_bus_index("Alarm")

# Create new ConfigFile object for saving/loading.
var config = ConfigFile.new()


func _process(_delta: float) -> void:
	pass
	
										#### menu buttons ####
# new game
func _on_button_new_pressed() -> void:
	Game.is_new_game = true
	get_tree().change_scene_to_file("res://scenes/main.tscn")

# load game
func _on_button_load_pressed() -> void:
	$menu.visible = false
	$load.visible = true
	
# settings
func _on_button_settings_pressed() -> void:
	$menu.visible = false
	$settings.visible = true

# quit
func _on_button_quit_pressed() -> void:
	get_tree().quit()

# back button from settings context
func _on_button_pressed_back() -> void:
	$settings.visible = false
	$load.visible = false
	$menu.visible = true
	

func _ready() -> void:	
	
	var texture = load("res://textures/badtitle.png")
	$menu/TextureRect.texture = texture
	
	var dir = DirAccess.open("user://")
	if dir:
		if not dir.dir_exists("saves"):
			dir.make_dir("saves")
	
	# disable window options if runing in editor	
	if Engine.is_embedded_in_editor():
		window_options.disabled = true
	
	# update window disply mode in settings	
	var current_mode = DisplayServer.window_get_mode()
	match current_mode:
		DisplayServer.WINDOW_MODE_WINDOWED:
			window_options.select(0)
		DisplayServer.WINDOW_MODE_FULLSCREEN:
			window_options.select(1)
		DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			window_options.select(2)
			
	# load settings file
	var err = config.load("user://settings.cfg")
		
	# If the file didn't load, ignore it
	if err != OK:
		pass
	else:
		slider_music.value = config.get_value("volume", "music")
		slider_clicks.value = config.get_value("volume", "clicks")
		slider_amb.value = config.get_value("volume", "amb")
		slider_sfx.value = config.get_value("volume", "sfx")
		slider_alarm.value = config.get_value("volume", "alarms")

# window selection mode
func _on_option_button_item_selected(index: int) -> void:
	if(index == 2):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	elif(index == 1):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	

#open save folder
func _on_button_savefldr_pressed() -> void:
	var dir = DirAccess.open("user://")
	if dir:
		if not dir.dir_exists("saves"):
			dir.make_dir("saves")
			
	OS.shell_open(ProjectSettings.globalize_path("user://saves"))


func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(audio_music_bus, linear_to_db(value))
	config.set_value("volume", "music", value)
	_save_config()

func _on_click_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(audio_click_bus, linear_to_db(value))
	config.set_value("volume", "clicks", value)
	_save_config()

func _on_amb_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(audio_amb_bus, linear_to_db(value))
	config.set_value("volume", "amb", value)
	_save_config()

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(audio_sfx_bus, linear_to_db(value))
	config.set_value("volume", "sfx", value)
	_save_config()

func _on_alarm_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(audio_alarm_bus, linear_to_db(value))
	config.set_value("volume", "alarms", value)
	_save_config()
	
func _save_config():
	config.save("user://settings.cfg")
