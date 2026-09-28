extends Node

var is_new_game: bool = true
var game_save_index:int

#game stats
var time_points:float = 1000000 if Constants.dev else 0
var isDataUnlocked = false
var cumlative_points:int = 0
var cumlative_points_rollover:int = 0
var base_mult:float = 0.0 #global multiplier
var multiplier:float = Constants.base_multiplier * 1.0
var hundredkprogess:int = 0 #second currency
var discount:float = 1.000
var lives:int = Constants.starting_lives

#unused
var isMultUnlocked = true
var isUpgradesUnlocked = true

#ui
var ui_decimal_count = 0
const panel_size:int = Constants.ui_panel_standard_size
var selected 

signal updated_selected
signal discount_purchased
signal data_purchased
signal game_loaded

signal shop_item_clicker_loaded(ref)
var linked_async_shop_item_clicker
signal shop_item_pet_loaded(ref)
var linked_async_shop_item_pet
signal shop_item_ticker_loaded(ref)
var linked_async_shop_item_ticker
signal shop_item_timer_button_loaded(ref)
var linked_async_shop_item_timer_button
signal shop_item_timer_defuse_loaded(ref)
var linked_async_shop_item_timer_defuse

func _ready() -> void:
	game_loaded.connect(_game_loaded)
	
	#register signals to alert when shop items are loaded and initilized
	shop_item_clicker_loaded.connect(_shop_item_clicker_loaded)
	shop_item_pet_loaded.connect(_shop_item_pet_loaded)
	shop_item_ticker_loaded.connect(_shop_item_ticker_loaded)
	shop_item_timer_button_loaded.connect(_shop_item_timer_button_loaded)
	shop_item_timer_defuse_loaded.connect(_shop_item_timer_defuse_loaded)

func checkprogressandrollover():
	if cumlative_points_rollover >= 100000:
		cumlative_points_rollover -= 100000
		hundredkprogess += 1
		print("100k point")

# includes multiplier
func add_time_point():
	time_points += 1.0 * multiplier
	cumlative_points += ceil(1.0 * multiplier)
	cumlative_points_rollover +=  ceil(1.0 * multiplier)
	checkprogressandrollover()
	
# does not include multiplier
func add_time_points(_p:float):
	time_points += _p
	cumlative_points +=  ceil(_p)
	cumlative_points_rollover +=  ceil(_p)
	checkprogressandrollover()
	
func remove_time_points(_p:float):
	time_points -= _p

func get_points() -> float:
	return time_points

func add_life():
	lives += 1

func remove_life():
	if(lives - 1 > 0):
		lives -= 1
	else:
		print("you died")
	
func get_multiplier():
	return multiplier + base_mult

func add_to_multiplier( _f: float):
	multiplier =+ _f
	
func recalc_price(_in:float) -> float:
	return (_in * 1.25) + (100 * Game.multiplier)

func add_base_mult(_in:float):
	base_mult += _in
	
func set_selected(_in):
	selected = _in
	updated_selected.emit()
	
func doDataUpdate():
	isDataUnlocked = true
	data_purchased.emit()
	
func doDiscountUpdate():
	if(discount - 0.01 > 0):
		discount -= 0.01
		discount_purchased.emit()
	else:
		var button:Button = %Button_data_upgrade
		var label:Label = %Label_Price_data_upgrade
		button.disabled = true
		label.text = "out of stock"
		

#const SAVE_PATH = "user://saves/save_json.json"


func save_game() -> void:
#bowsers contribution
#	;l.
#0 1
	var stats_node:  = get_node("/root/Control/game/HBoxContainer/VBoxContainer_UI/ColorRect/container_scorer_ver")
	
	# calculate what save file to save into
	var savegame_file = Constants.SAVE_PATH + "save_game_" + str(game_save_index) + ".json"
	
	var file := FileAccess.open(savegame_file, FileAccess.WRITE)

	var stats := stats_node
	# JSON doesn't support many of Godot's types such as Vector2.
	# var_to_str can be used to convert any Variant to a String.
	var save_dict := {
		stats = {
			time_points = var_to_str(time_points),
			isDataUnlocked = var_to_str(isDataUnlocked),
			cumlative_points = var_to_str(cumlative_points),
			cumlative_points_rollover = var_to_str(cumlative_points_rollover),
			base_mult = var_to_str(base_mult),
			multiplier = var_to_str(multiplier),
			hundredkprogess = var_to_str(hundredkprogess),
			discount = var_to_str(discount),
			lives = var_to_str(lives),
			game_save_index = var_to_str(game_save_index)
		},
		distractionz = [],
		shopItemz = [],
	}

	#gather data from nodes we generated
	#distraction nodes
	for d in get_tree().get_first_node_in_group("distraction_target").get_children():
		save_dict.distractionz.push_back({
			data = d.getSaveData(),
		})
	
	#shop entries
	for s in get_tree().get_nodes_in_group("shopItem"):
		save_dict.shopItemz.push_back({
			data = s.getSaveData(),
		})
		
	

	file.store_line(JSON.stringify(save_dict))

# game loaded ready callback
func _game_loaded():
	var _save_files_index = 0
	
	if !is_new_game:
		print("loading saved game")
		#load_game updates save file index to save into correct file
		load_game(game_save_index)
	else:
		print("creating new game")
		
		# count how many save files exist
		if DirAccess.dir_exists_absolute(Constants.SAVE_PATH):
			var files = DirAccess.get_files_at(Constants.SAVE_PATH)
			for file in files:
				_save_files_index += 1
		
		#increment save file inxed to save into new file
		game_save_index = _save_files_index + 1
		
		
		# reset variables
		time_points = 1000000 if Constants.dev else 0
		isDataUnlocked = false
		cumlative_points = 0
		cumlative_points_rollover = 0
		base_mult = 0.0 
		multiplier = 1
		hundredkprogess = 0
		discount = 1.000
		lives = Constants.starting_lives
		
		

func load_game(save_index:int) -> void:
	var savegame_file = Constants.SAVE_PATH + "save_game_" + str(save_index) + ".json"
	var file := FileAccess.open(savegame_file, FileAccess.READ)
	#if there is no save file
	if(file == null):
		return
	
	var json := JSON.new()
	json.parse(file.get_line())
	var save_dict := json.get_data() as Dictionary
	var distraction_target = get_tree().get_first_node_in_group("distraction_target")

	#preload assets
	var _distraction_clicker = preload("res://scenes/distractions/distraction_clicker.tscn")
	var _distraction_pet = preload("res://scenes/distractions/distraction_pet.tscn")
	var _distraction_ticker = preload("res://scenes/distractions/distraction_ticker.tscn")
	var _distraction_timer_button = preload("res://scenes/distractions/distraction_timer_button.tscn")
	var _distraction_timer_suprise = preload("res://scenes/distractions/distraction_timer_suprise.tscn")
	
	# Remove existing objects before adding new ones.
	get_tree().call_group("distraction", "queue_free")
	get_tree().call_group("upgradeItem", "queue_free")
	#get_tree().call_group("shopItem", "queue_free")
	
	#populate game data
	time_points = str_to_var(save_dict.stats.time_points)
	cumlative_points = str_to_var(save_dict.stats.cumlative_points)
	cumlative_points_rollover = str_to_var(save_dict.stats.cumlative_points_rollover)
	base_mult = str_to_var(save_dict.stats.base_mult)
	hundredkprogess = str_to_var(save_dict.stats.hundredkprogess)
	discount = str_to_var(save_dict.stats.discount)
	lives = str_to_var(save_dict.stats.lives)
	multiplier = str_to_var(save_dict.stats.multiplier)
	isDataUnlocked = str_to_var(save_dict.stats.isDataUnlocked)
	game_save_index = str_to_var(save_dict.stats.game_save_index)

#for every saved distraction
	for distract: Dictionary in save_dict.distractionz:
		var distraction_ref
		var enumtype:Constants.Type = distract.data.type
		
		#select which type of distraction to create
		if(enumtype == Constants.Type.CLICKER):
			distraction_ref = _distraction_clicker
		elif(enumtype == Constants.Type.PET):
			distraction_ref = _distraction_pet
		elif(enumtype == Constants.Type.TICKER):
			distraction_ref = _distraction_ticker
		elif(enumtype == Constants.Type.TIMER_BUTTON):
			distraction_ref = _distraction_timer_button
		elif(enumtype == Constants.Type.TIMER_SUPRISE):
			distraction_ref = _distraction_timer_suprise
		
		#new template item
		var item:Distraction = distraction_ref.instantiate()
		#fill in data
		item.savedata = distract.data.stats.duplicate()
		item.UI_MODE = false
		item.loading_from_save = true
		item.loadSaveData()
		#commit to scene tree
		distraction_target.add_child(item)
	
	#for saved shop entries
	for shopies: Dictionary in save_dict.shopItemz:
		if(str_to_var(shopies.data.stats.id) == "clicker"):	
			linked_async_shop_item_clicker.loadSaveData(shopies.data.stats)
		elif(str_to_var(shopies.data.stats.id) == "pet"):
			linked_async_shop_item_pet.loadSaveData(shopies.data.stats)
		elif(str_to_var(shopies.data.stats.id) == "ticker"):
			linked_async_shop_item_ticker.loadSaveData(shopies.data.stats)
		elif(str_to_var(shopies.data.stats.id) == "timer"):
			linked_async_shop_item_timer_button.loadSaveData(shopies.data.stats)
		elif(str_to_var(shopies.data.stats.id) == "bomb"):
			linked_async_shop_item_timer_defuse.loadSaveData(shopies.data.stats)
	
		
		
func _shop_item_clicker_loaded(node_reference):
	linked_async_shop_item_clicker = node_reference
	
func _shop_item_pet_loaded(node_reference):
	linked_async_shop_item_pet = node_reference
	
func _shop_item_ticker_loaded(node_reference):
	linked_async_shop_item_ticker = node_reference
	
func _shop_item_timer_button_loaded(node_reference):
	linked_async_shop_item_timer_button = node_reference
	
func _shop_item_timer_defuse_loaded(node_reference):
	linked_async_shop_item_timer_defuse = node_reference
