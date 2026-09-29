extends "res://scripts/disctactions/distraction.gd"

var ticker:float
var timer:Timer
var scorer:Timer
var label:Label
var checklabel:Label
var checkbutton:CheckButton
var button:Button

var isChecked
var modifier = 2
var lastvalue = 100
var alarmtriggered

var initcount = 100

func present_init_upgrade_data():
	self.upgrade_level_1_title = "Amount"
	self.upgrade_level_1_desc = "+3"
	self.upgrade_level_1_price = 1500
	self.upgrade_level_1_price_increase = 1.20
	self.upgrade_level_1_level_string = "0"
	
	self.upgrade_level_2_title = "multiplier"
	self.upgrade_level_2_desc = "+0.1x"
	self.upgrade_level_2_price = 2000
	self.upgrade_level_2_price_increase = 2
	self.upgrade_level_2_level_string = "0"
	
	self.upgrade_level_3_title = "alarm"
	self.upgrade_level_3_desc = "get an alarm"
	self.upgrade_level_3_price = 100000
	self.upgrade_level_3_one_time = true
	self.upgrade_level_3_price_increase = 1
	self.upgrade_level_3_level_string = "available"
	
	self.upgrade_level_4_title = "offset"
	self.upgrade_level_4_desc = "+ x1"
	self.upgrade_level_4_price = 15000
	self.upgrade_level_4_price_increase = 1.5
	self.upgrade_level_4_level_string = "0"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer = get_node("Timer")
	scorer = get_node("Timer_Scorer")
	label = get_node("Label")
	button = get_node("Button")
	checkbutton = get_node("CheckButton")
	checklabel = get_node("CheckButton/Label")
	Game.data_purchased.connect(update_labels)
	
	if(self.UI_MODE):
		button.disabled = true
		checkbutton.disabled = true
	else:
		timer.start()
		_on_timer_scorer_timeout()
		_on_check_button_pressed()
				#for upgrade
		var upgrade_node_target = get_node("../../../../../HBoxContainer/VBoxContainer_UI_Upgrade/ColorRect/VBoxContainer/upgrade/ScrollContainer/VBoxContainer")
		var u:upgrade_item = upgrade.instantiate()
		u.loading_from_save = self.loading_from_save
		u.link(self)
		upgrade_node_target.add_child(u)
		self.upgrade_reference = u
			
func init() -> void:
	self.ticker = initcount
	self.title = "ticker"
	self.price = 5000
	self.amount = 1
	self.lastvalue = initcount
	
func update_labels():
	self.upgrade_level_1_level_string = str(upgrade_level_1_level)
	self.upgrade_level_2_level_string = str(upgrade_level_2_level)
	self.upgrade_level_3_level_string = "purchased" if upgrade_level_3_level == 1 else "available"
	self.upgrade_level_4_level_string = str(upgrade_level_4_level)
	
#Amount
func upgrade_1():
	if(self.upgrade_level_1_price * Game.discount <= Game.get_points()):
		Game.remove_time_points(upgrade_level_1_price * Game.discount)
		self.upgrade_level_1_price = upgrade_level_1_price * Game.discount * upgrade_level_1_price_increase
		self.upgrade_level_1_level = upgrade_level_1_level + 1
		
		#upgrade
		self.amount += 3
		update_labels()
		return true
	else:
		return false
		
#Multiplier
func upgrade_2():
	if(self.upgrade_level_2_price * Game.discount <= Game.get_points()):
		Game.remove_time_points(upgrade_level_2_price * Game.discount)
		self.upgrade_level_2_price = upgrade_level_2_price * Game.discount * upgrade_level_2_price_increase
		self.upgrade_level_2_level = upgrade_level_2_level + 1
		
		#upgrade
		self.mult += 0.1
		update_labels()
		return true
	else:
		return false

#alarm	
func upgrade_3():
	if(self.upgrade_level_3_price * Game.discount <= Game.get_points()):
		Game.remove_time_points(upgrade_level_3_price * Game.discount)
		self.upgrade_level_3_price = upgrade_level_3_price * Game.discount * upgrade_level_3_price_increase
		self.upgrade_level_3_level = upgrade_level_3_level + 1
		
		#upgrade
		self.alarm = true
		update_labels()
		return true
	else:
		return false

#tick amount
func upgrade_4():
	if(self.upgrade_level_4_price * Game.discount <= Game.get_points()):
		Game.remove_time_points(upgrade_level_4_price * Game.discount)
		self.upgrade_level_4_price = upgrade_level_4_price * Game.discount * upgrade_level_4_price_increase
		self.upgrade_level_4_level = upgrade_level_4_level + 1
		#upgrade
		self.modifier += 1
		checklabel.text = "x" + str(self.modifier)
		update_labels()
		return true
	else:
		return false

func update_labels_internal():	
	var a = self.modifier * self.amount * (Game.get_multiplier() + self.mult)
	var b = 1 * self.amount * (Game.get_multiplier() + self.mult)
	isChecked = checkbutton.button_pressed
	
	var increment_score = a if isChecked else b
	button.text = "+" + str(increment_score)
	
func _on_timer_timeout() -> void:
	var a = self.modifier * self.amount * (Game.get_multiplier() + self.mult)
	var b = 1 * self.amount * (Game.get_multiplier() + self.mult)
	var increment_score = a if isChecked else b
	timer.start(1)
	ticker = ticker - increment_score
	label.text = str(ticker)
	update_labels_internal()
	
	#alarm
	if(ticker <= lastvalue / 4.0 and ticker != 0 and !alarmtriggered):
		alarmtriggered = true
		print("---distraction : ticker - _on_timer_timeout()----")
		print("ticker: " + str(ticker))
		print("lastvalue: " + str(lastvalue))
		print("lastvalue / 4.0 = " + str(lastvalue / 4.0))
	#run out
	elif(ticker <= 0):
		self.lastvalue = initcount
		timer.stop()
		scorer.stop()
		_timeout()
		init()
		timer.start()
		_on_timer_scorer_timeout()
		_on_check_button_pressed()
		alarmlogic()
		
	
	
func alarmlogic():
	if(alarm):
		if(!alarmtriggered):
			if(ticker != 0):
				self.color = Color(1.0, 1.0, 1.0, 1.0)
		else:
			if(ticker <= 1):
				self.color = Color(0.41, 0.139, 0.139, 1.0)
			else:
				self.color = Color(1.0, 0.34, 0.34, 1.0)
				
func _on_check_button_pressed() -> void:
	update_labels_internal()

func _on_button_pressed() -> void:
	var a = self.modifier * self.amount * (Game.get_multiplier() + self.mult)
	var b = 1 * self.amount * (Game.get_multiplier() + self.mult)
	var increment_score = a if isChecked else b
	
	ticker = ticker + increment_score
	Game.add_time_points(increment_score)	
	label.text = str(ticker)
	if(ticker > lastvalue):
		lastvalue = ticker
	alarmtriggered = false
	particle_tree = p.instantiate()
	add_child(particle_tree)
	particle_tree.emit(increment_score,2.0)
	
func _on_timer_scorer_timeout() -> void:
	var a = self.modifier * self.amount * (Game.get_multiplier() + self.mult)
	var b = 1 * self.amount * (Game.get_multiplier() + self.mult)
	var increment_score = a if isChecked else b
	Game.add_time_points(increment_score)
	
	particle_tree = p.instantiate()
	add_child(particle_tree)
	particle_tree.emit_speed(increment_score,2.0,.02)
	
	scorer.start(1)
	
func _timeout():
	Game.remove_life()
	self.alarmtriggered = false
	print("---distraction : ticker - timeout()----")
	print("ticker timeout")
	
func _on_gui_input(event: InputEvent) -> void:
	if not self.UI_MODE:
		if event is not InputEventMouseMotion:
			if event.pressed:
				Game.set_selected(self)
				
#save/load 
#gather all info to be saved
func getSaveData() -> Dictionary:
	var save_dict := {
		type = Constants.Type.TICKER,
		stats = {
			title = var_to_str(self.title),
			price = var_to_str(self.price),
			amount = var_to_str(self.amount),
			alarm = var_to_str(self.alarm),
			isChecked = var_to_str(self.isChecked),
			modifier = var_to_str(self.modifier),#offset upgrade
			upgrade_level_1_desc = var_to_str(self.upgrade_level_1_desc),
			upgrade_level_1_disabled = var_to_str(self.upgrade_level_1_disabled),
			upgrade_level_1_level = var_to_str(self.upgrade_level_1_level),
			upgrade_level_1_level_limit = var_to_str(self.upgrade_level_1_level_limit),
			upgrade_level_1_level_string = var_to_str(self.upgrade_level_1_level_string),
			upgrade_level_1_one_time = var_to_str(self.upgrade_level_1_one_time),
			upgrade_level_1_price = var_to_str(self.upgrade_level_1_price),
			upgrade_level_1_price_increase = var_to_str(self.upgrade_level_1_price_increase),
			upgrade_level_1_title = var_to_str(self.upgrade_level_1_title),
			upgrade_level_2_desc = var_to_str(self.upgrade_level_2_desc),
			upgrade_level_2_disabled = var_to_str(self.upgrade_level_2_disabled),
			upgrade_level_2_level = var_to_str(self.upgrade_level_2_level),
			upgrade_level_2_level_limit = var_to_str(self.upgrade_level_2_level_limit),
			upgrade_level_2_level_string = var_to_str(self.upgrade_level_2_level_string),
			upgrade_level_2_one_time = var_to_str(self.upgrade_level_2_one_time),
			upgrade_level_2_price = var_to_str(self.upgrade_level_2_price),
			upgrade_level_2_price_increase = var_to_str(self.upgrade_level_2_price_increase),
			upgrade_level_2_title = var_to_str(self.upgrade_level_2_title),
			upgrade_level_3_desc = var_to_str(self.upgrade_level_3_desc),
			upgrade_level_3_disabled = var_to_str(self.upgrade_level_3_disabled),
			upgrade_level_3_level = var_to_str(self.upgrade_level_3_level),
			upgrade_level_3_level_limit = var_to_str(self.upgrade_level_3_level_limit),
			upgrade_level_3_level_string = var_to_str(self.upgrade_level_3_level_string),
			upgrade_level_3_one_time = var_to_str(self.upgrade_level_3_one_time),
			upgrade_level_3_price = var_to_str(self.upgrade_level_3_price),
			upgrade_level_3_price_increase = var_to_str(self.upgrade_level_3_price_increase),
			upgrade_level_3_title = var_to_str(self.upgrade_level_3_title),
			upgrade_level_4_desc = var_to_str(self.upgrade_level_4_desc),
			upgrade_level_4_disabled = var_to_str(self.upgrade_level_4_disabled),
			upgrade_level_4_level = var_to_str(self.upgrade_level_4_level),
			upgrade_level_4_level_limit = var_to_str(self.upgrade_level_4_level_limit),
			upgrade_level_4_level_string = var_to_str(self.upgrade_level_4_level_string),
			upgrade_level_4_one_time = var_to_str(self.upgrade_level_4_one_time),
			upgrade_level_4_price = var_to_str(self.upgrade_level_4_price),
			upgrade_level_4_price_increase = var_to_str(self.upgrade_level_4_price_increase),
			upgrade_level_4_title = var_to_str(self.upgrade_level_4_title),
		},
	}
	return save_dict
	
func loadSaveData():
	self.title = str_to_var(savedata.title)
	self.price = str_to_var(savedata.price)
	self.amount = str_to_var(savedata.amount)
	self.isChecked = str_to_var(savedata.isChecked)
	self.alarm = str_to_var(savedata.alarm)
	self.upgrade_level_1_desc = str_to_var(savedata.upgrade_level_1_desc)
	self.upgrade_level_1_disabled = str_to_var(savedata.upgrade_level_1_disabled)
	self.upgrade_level_1_level = str_to_var(savedata.upgrade_level_1_level)
	self.upgrade_level_1_level_limit = str_to_var(savedata.upgrade_level_1_level_limit)
	self.upgrade_level_1_level_string = str_to_var(savedata.upgrade_level_1_level_string)
	self.upgrade_level_1_one_time = str_to_var(savedata.upgrade_level_1_one_time)
	self.upgrade_level_1_price = str_to_var(savedata.upgrade_level_1_price)
	self.upgrade_level_1_price_increase = str_to_var(savedata.upgrade_level_1_price_increase)
	self.upgrade_level_1_title = str_to_var(savedata.upgrade_level_1_title)
	self.upgrade_level_2_desc = str_to_var(savedata.upgrade_level_2_desc)
	self.upgrade_level_2_disabled = str_to_var(savedata.upgrade_level_2_disabled)
	self.upgrade_level_2_level = str_to_var(savedata.upgrade_level_2_level)
	self.upgrade_level_2_level_limit = str_to_var(savedata.upgrade_level_2_level_limit)
	self.upgrade_level_2_level_string = str_to_var(savedata.upgrade_level_2_level_string)
	self.upgrade_level_2_one_time = str_to_var(savedata.upgrade_level_2_one_time)
	self.upgrade_level_2_price = str_to_var(savedata.upgrade_level_2_price)
	self.upgrade_level_2_price_increase = str_to_var(savedata.upgrade_level_2_price_increase)
	self.upgrade_level_2_title = str_to_var(savedata.upgrade_level_2_title)
	self.upgrade_level_3_desc = str_to_var(savedata.upgrade_level_3_desc)
	self.upgrade_level_3_disabled = str_to_var(savedata.upgrade_level_3_disabled)
	self.upgrade_level_3_level = str_to_var(savedata.upgrade_level_3_level)
	self.upgrade_level_3_level_limit = str_to_var(savedata.upgrade_level_3_level_limit)
	self.upgrade_level_3_level_string = str_to_var(savedata.upgrade_level_3_level_string)
	self.upgrade_level_3_one_time = str_to_var(savedata.upgrade_level_3_one_time)
	self.upgrade_level_3_price = str_to_var(savedata.upgrade_level_3_price)
	self.upgrade_level_3_price_increase = str_to_var(savedata.upgrade_level_3_price_increase)
	self.upgrade_level_3_title = str_to_var(savedata.upgrade_level_3_title)
	self.upgrade_level_4_desc = str_to_var(savedata.upgrade_level_4_desc)
	self.upgrade_level_4_disabled = str_to_var(savedata.upgrade_level_4_disabled)
	self.upgrade_level_4_level = str_to_var(savedata.upgrade_level_4_level)
	self.upgrade_level_4_level_limit = str_to_var(savedata.upgrade_level_4_level_limit)
	self.upgrade_level_4_level_string = str_to_var(savedata.upgrade_level_4_level_string)
	self.upgrade_level_4_one_time = str_to_var(savedata.upgrade_level_4_one_time)
	self.upgrade_level_4_price = str_to_var(savedata.upgrade_level_4_price)
	self.upgrade_level_4_price_increase = str_to_var(savedata.upgrade_level_4_price_increase)
	self.upgrade_level_4_title = str_to_var(savedata.upgrade_level_4_title)
