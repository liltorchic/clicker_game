extends "res://scripts/disctactions/distraction.gd"
var timer:Timer
var label:Label
var scorer:Timer
var button:Button
var timer_length:float = 10
var scorer_increment = 1

func present_init_upgrade_data():
	self.upgrade_level_1_title = "click amount"
	self.upgrade_level_1_desc = "+2"
	self.upgrade_level_1_price = 100
	self.upgrade_level_1_price_increase = 3
	self.upgrade_level_1_level_string = "0"
	
	self.upgrade_level_2_title = "multiplier"
	self.upgrade_level_2_desc = "+0.1x"
	self.upgrade_level_2_price = 1000
	self.upgrade_level_2_price_increase = 1.25
	self.upgrade_level_2_level_string = "0"
	
	self.upgrade_level_3_title = "countdown"
	self.upgrade_level_3_desc = "1.5x"
	self.upgrade_level_3_price = 10000
	self.upgrade_level_3_price_increase = 1.25
	self.upgrade_level_3_level_string = "0"
	
	self.upgrade_level_4_title = "score frequency"
	self.upgrade_level_4_desc = "66% faster"
	self.upgrade_level_4_price = 2500
	self.upgrade_level_4_price_increase = 3
	self.upgrade_level_4_level_string = "0"
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	label.text = str("%.2f" % [timer.time_left])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer = get_node("Timer")
	label = get_node("Label")
	scorer = get_node("Timer_Scorer")
	button = get_node("Button")
	Game.data_purchased.connect(update_labels)
	
	if(self.UI_MODE):
		button.disabled = true
	else:
		timer.start(timer_length)
		_on_timer_scorer_timeout()
				#for upgrade
		var upgrade_node_target = get_node("../../../../../HBoxContainer/VBoxContainer_UI_Upgrade/ColorRect/VBoxContainer/upgrade/ScrollContainer/VBoxContainer")
		var u:upgrade_item = upgrade.instantiate()
		u.loading_from_save = self.loading_from_save
		u.link(self)
		upgrade_node_target.add_child(u)
		self.upgrade_reference = u
		
func init() -> void:
	self.title = "timer"
	self.price = 100
	self.amount = 8
	self.scorer_increment = 1
	
func update_labels():
	self.upgrade_level_1_level_string = str(upgrade_level_1_level)
	self.upgrade_level_2_level_string = str(upgrade_level_2_level)
	self.upgrade_level_3_level_string = str(upgrade_level_3_level)
	self.upgrade_level_4_level_string = str(upgrade_level_4_level) if upgrade_level_4_level < 3 else "max"
	
#Amount
func upgrade_1():
	if(self.upgrade_level_1_price  * Game.discount<= Game.get_points()):
		Game.remove_time_points(upgrade_level_1_price * Game.discount)
		self.upgrade_level_1_price = upgrade_level_1_price * Game.discount * upgrade_level_1_price_increase
		self.upgrade_level_1_level = upgrade_level_1_level + 1
		
		#upgrade
		self.amount += 2
		update_labels()
		return true
	else:
		return false
		
#Multiplier
func upgrade_2():
	if(self.upgrade_level_2_price  * Game.discount<= Game.get_points()):
		Game.remove_time_points(upgrade_level_2_price * Game.discount)
		self.upgrade_level_2_price = upgrade_level_2_price * Game.discount * upgrade_level_2_price_increase
		self.upgrade_level_2_level = upgrade_level_2_level + 1
		
		#upgrade
		self.mult += 0.1
		update_labels()
		return true
	else:
		return false

#tick amount
func upgrade_3():
	if(self.upgrade_level_3_price * Game.discount <= Game.get_points()):
		Game.remove_time_points(upgrade_level_3_price * Game.discount)
		self.upgrade_level_3_price = upgrade_level_3_price * Game.discount * upgrade_level_3_price_increase
		self.upgrade_level_3_level = upgrade_level_3_level + 1
		
		#upgrade
		self.timer_length = self.timer_length * 1.5
		update_labels()
		return true
	else:
		return false

#freq
func upgrade_4():
	if(self.upgrade_level_4_price * Game.discount <= Game.get_points()):
		Game.remove_time_points(upgrade_level_4_price * Game.discount)
		self.upgrade_level_4_price = upgrade_level_4_price * Game.discount * upgrade_level_4_price_increase
		self.upgrade_level_4_level = upgrade_level_4_level + 1
		
		if(upgrade_level_4_level >= 6):
			self.upgrade_level_4_disabled = true
			
		scorer_increment *= .66
		scorer.start(scorer_increment)
		update_labels()
		return true
	else:
		return false


func _on_timer_timeout() -> void:
	timer.stop()
	scorer.stop()
	label.text = "0.00"
	Game.remove_life()
	print("simple timer timeout")

#reset button
func _on_button_pressed() -> void:
	timer.start(timer_length)
	scorer.start(scorer_increment)
	self.color = Color(1.0, 1.0, 1.0, 1.0)
	
func _on_timer_scorer_timeout() -> void:
	var reward = self.amount * (Game.get_multiplier() + self.mult)
	scorer.start(scorer_increment)
	particle_tree = p.instantiate()
	add_child(particle_tree)
	particle_tree.emit_speed(reward, 1.0, .02)
	Game.add_time_points(reward)
	
	
func _on_gui_input(event: InputEvent) -> void:
	if not self.UI_MODE:
		if event is not InputEventMouseMotion:
			if event.pressed:
				Game.set_selected(self)
				
#save/load
#gather all info to be saved
func getSaveData() -> Dictionary:
	var save_dict := {
		type = Constants.Type.TIMER_BUTTON,
		stats = {
			title = var_to_str(self.title),
			price = var_to_str(self.price),
			amount = var_to_str(self.amount),
			mult = var_to_str(self.mult),
			alarm = var_to_str(self.alarm),
			timer_length = var_to_str(self.timer_length),
			scorer_increment = var_to_str(self.scorer_increment),
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
	self.mult = str_to_var(savedata.mult)
	self.alarm = str_to_var(savedata.alarm)
	self.timer_length = str_to_var(savedata.timer_length)
	self.scorer_increment = str_to_var(savedata.scorer_increment)
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
	
