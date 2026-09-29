extends "res://scripts/disctactions/distraction.gd"

var countdown_timer:Timer
var hidden_timer:Timer
var scorer:Timer
var label:Label
var button:Button

var rng = RandomNumberGenerator.new()

var timer_hidden:bool

var timer_amount:int = 3
var timer_rng_lower:int = 6
var timer_rng_upper:int = 12

func present_init_upgrade_data():
	self.upgrade_level_1_title = "amount"
	self.upgrade_level_1_desc = "+10"
	self.upgrade_level_1_price = 100
	self.upgrade_level_1_price_increase = 1.5
	self.upgrade_level_1_level_string = "0"
	
	self.upgrade_level_2_title = "multiplier"
	self.upgrade_level_2_desc = "+0.1x"
	self.upgrade_level_2_price = 1000
	self.upgrade_level_2_price_increase = 1.25
	self.upgrade_level_2_level_string = "0"
	
	self.upgrade_level_3_title = "peace"
	self.upgrade_level_3_desc = "rest easier"
	self.upgrade_level_3_price = 1000
	self.upgrade_level_3_price_increase = 1.1
	self.upgrade_level_3_level_string = "0"
	
	self.upgrade_level_4_title = "alarm"
	self.upgrade_level_4_desc = "get an alarm"
	self.upgrade_level_4_price = 100000
	self.upgrade_level_4_one_time = true
	self.upgrade_level_4_level_string = "available"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if(!timer_hidden):
		label.text =  str("%.2f" % [countdown_timer.time_left])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	countdown_timer = get_node("TimerCountdown")
	hidden_timer = get_node("TimerHidden")
	label = get_node("Label")
	button = get_node("Button")
	label.text = ""
	timer_hidden = true
	button.visible = false
	Game.data_purchased.connect(update_labels)
	
	if(self.UI_MODE):
		button.disabled = true
	else:
		countdown_timer.set_wait_time(timer_amount + 0.01) # +0.01 so the scorewr can score on 0.00
		hidden_timer.start(rng.randf_range(timer_rng_lower, timer_rng_upper))
				#for upgrade
		var upgrade_node_target = get_node("../../../../../HBoxContainer/VBoxContainer_UI_Upgrade/ColorRect/VBoxContainer/upgrade/ScrollContainer/VBoxContainer")
		var u:upgrade_item = upgrade.instantiate()
		u.loading_from_save = self.loading_from_save
		u.link(self)
		upgrade_node_target.add_child(u)
		self.upgrade_reference = u
		

func init() -> void:
	self.title = "bomb"
	self.price = 200
	

func update_labels():
	self.upgrade_level_1_level_string = str(upgrade_level_1_level)
	self.upgrade_level_2_level_string = str(upgrade_level_2_level)
	self.upgrade_level_3_level_string = str(upgrade_level_3_level)
	self.upgrade_level_4_level_string = "purchased" if upgrade_level_4_level == 1 else "available"
	
#Amount
func upgrade_1():
	if(self.upgrade_level_1_price * Game.discount <= Game.get_points()):
		Game.remove_time_points(upgrade_level_1_price * Game.discount)
		self.upgrade_level_1_price = upgrade_level_1_price * Game.discount * upgrade_level_1_price_increase
		self.upgrade_level_1_level = upgrade_level_1_level + 1
		
		#upgrade
		self.amount += 10
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

#peace	
func upgrade_3():
	if(self.upgrade_level_3_price * Game.discount <= Game.get_points()):
		Game.remove_time_points(upgrade_level_3_price * Game.discount)
		self.upgrade_level_3_price = upgrade_level_3_price * Game.discount * upgrade_level_3_price_increase
		self.upgrade_level_3_level = upgrade_level_3_level + 1
		
		#upgrade
		self.timer_amount += 1
		self.timer_rng_lower += 1
		self.timer_rng_upper += 2
		update_labels()
		return true
	else:
		return false

#alarm
func upgrade_4():
	if(self.upgrade_level_4_price * Game.discount <= Game.get_points()):
		Game.remove_time_points(upgrade_level_4_price * Game.discount)
		self.upgrade_level_4_price = upgrade_level_4_price * Game.discount * upgrade_level_4_price_increase
		self.upgrade_level_4_level = upgrade_level_4_level + 1
		#upgrade
		self.alarm = true
		update_labels()
		return true
	else:
		return false
	

#reset
func _on_timer_hidden_timeout() -> void:
	if(alarm):
		self.color = Color(0.996, 0.806, 0.395, 1.0)
	timer_hidden = false
	button.visible = true
	countdown_timer.start()
	
	
#you lose
func _on_timer_countdown_timeout() -> void:
	countdown_timer.stop()
	hidden_timer.stop()
	label.text = "0.00"
	Game.remove_life()
	if(alarm):
		self.color = Color(0.814, 0.0, 0.05, 1.0)
	print("suprise defuse timeout")

#defuse
func _on_button_pressed() -> void:
	var reward = 20 + self.amount * (Game.get_multiplier() + self.mult)
	if(!countdown_timer.is_stopped()):
		Game.add_time_points(reward)	
	timer_hidden = true
	label.text = ""
	countdown_timer.stop()
	countdown_timer.set_wait_time(timer_amount)
	hidden_timer.start(rng.randf_range(timer_rng_lower, timer_rng_upper))
	button.visible = false
	particle_tree = p.instantiate()
	add_child(particle_tree)
	particle_tree.emit(reward,2.0)
	self.color = Color(1.0, 1.0, 1.0, 1.0)
	
func _on_gui_input(event: InputEvent) -> void:
	if not self.UI_MODE:
		if event is not InputEventMouseMotion:
			if event.pressed:
				Game.set_selected(self)
				
#save/load
#gather all info to be saved
func getSaveData() -> Dictionary:
	var save_dict := {
		type = Constants.Type.TIMER_SUPRISE,
		stats = {
			title = var_to_str(self.title),
			price = var_to_str(self.price),
			amount = var_to_str(self.amount),
			mult = var_to_str(self.mult),
			alarm = var_to_str(self.alarm),
			timer_amount = var_to_str(self.timer_amount),
			timer_rng_lower = var_to_str(self.timer_rng_lower),
			timer_rng_upper = var_to_str(self.timer_rng_upper),
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
	self.timer_amount = str_to_var(savedata.timer_amount)
	self.timer_rng_lower = str_to_var(savedata.timer_rng_lower)
	self.timer_rng_upper = str_to_var(savedata.timer_rng_upper)
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
		
