extends Node

enum Type {UNDEFINED, AMOUNT, MULTIPLIER, AUTOCLICKER, BOOST, LOVE, TORTURE, ALARM, DURATION, BASE_LIVES, BASE_DATA, BASE_DISCOUNT}

@onready var title :Label = $ColorRect/VBoxContainer/Label_Title
#mult
@onready var upgrade_1_price :Label = $ColorRect/VBoxContainer/HBoxContainer/upgrade_1/HBoxContainer/Label_Price
@onready var upgrade_1_button :Button = $ColorRect/VBoxContainer/HBoxContainer/upgrade_1/HBoxContainer/Button
@onready var hbox_level_1 :HBoxContainer = $ColorRect/VBoxContainer/HBoxContainer/upgrade_1/level
@onready var data_label_1 :Label = $ColorRect/VBoxContainer/HBoxContainer/upgrade_1/level/Label
var upgrade_1_price_f:float = 1000.0
var upgrade_1_type:Type = Type.MULTIPLIER
var upgrade_1_level:int = 0

#lives
@onready var upgrade_2_price :Label = $ColorRect/VBoxContainer/HBoxContainer/upgrade_2/HBoxContainer/Label_Price
@onready var upgrade_2_button :Button = $ColorRect/VBoxContainer/HBoxContainer/upgrade_2/HBoxContainer/Button
@onready var hbox_level_2 :HBoxContainer = $ColorRect/VBoxContainer/HBoxContainer/upgrade_2/level
@onready var data_label_2 :Label = $ColorRect/VBoxContainer/HBoxContainer/upgrade_2/level/Label
var upgrade_2_price_f:float = 10000.0
var upgrade_2_type:Type = Type.BASE_LIVES
var upgrade_2_level:int = 0

#data
@onready var upgrade_3_price :Label = $ColorRect/VBoxContainer/HBoxContainer/upgrade_3/HBoxContainer/Label_Price
@onready var upgrade_3_button :Button = $ColorRect/VBoxContainer/HBoxContainer/upgrade_3/HBoxContainer/Button
@onready var hbox_level_3 :HBoxContainer = $ColorRect/VBoxContainer/HBoxContainer/upgrade_3/level
@onready var data_label_3 :Label = $ColorRect/VBoxContainer/HBoxContainer/upgrade_3/level/Label
var upgrade_3_price_f:float = 100.0
var upgrade_3_type:Type = Type.BASE_DATA


#discount
@onready var upgrade_4_price :Label = %Label_Price_data_upgrade
@onready var upgrade_4_button :Button = %Button_data_upgrade
@onready var hbox_level_4 :HBoxContainer = $ColorRect/VBoxContainer/HBoxContainer/upgrade_4/level
@onready var data_label_4 :Label = $ColorRect/VBoxContainer/HBoxContainer/upgrade_4/level/Label
var upgrade_4_price_f:float = 10000.0
var upgrade_4_type:Type = Type.BASE_DISCOUNT
var upgrade_4_level:int = 0
var upgrade_4_level_limit:int = 99

func _ready() -> void:
	update_price_labels()
	Game.discount_purchased.connect(_discount_purchased)
	Game.data_purchased.connect(_data_purchased)
	

func _discount_purchased():
	update_price_labels()
	
#called one time when data upgrade is bought 
func _data_purchased():
	hbox_level_1.visible = true
	hbox_level_2.visible = true
	hbox_level_3.visible = true
	hbox_level_4.visible = true
	data_label_3.text = ""
	data_label_4.text = "" 
	update_price_labels()

func update_price_labels():
	if(upgrade_1_price_f != -1):
		#update price label
		upgrade_1_price.text = str("%.0f" % [upgrade_1_price_f * Game.discount])
		#update extra data label
		data_label_1.text = str(upgrade_1_level)
	else:
		#update price label if its a one time purchase
		upgrade_1_price.text = ""
	
	if(upgrade_2_price_f != -1):
		#update price label
		upgrade_2_price.text = str("%.0f" % [upgrade_2_price_f * Game.discount])
		#update extra data label
		data_label_2.text = str(upgrade_2_level)
	else:
		#update price label if its a one time purchase
		upgrade_2_price.text = ""
		
	if(upgrade_3_price_f != -1):	
		#update price label
		upgrade_3_price.text = str("%.0f" % [upgrade_3_price_f * Game.discount])
	else:
		#update price label if its a one time purchase
		upgrade_3_price.text = "purchased"	
		
	if(upgrade_4_price_f != -1):		
		#update price label	
		upgrade_4_price.text = str("%.0f" % [upgrade_4_price_f * Game.discount])
	else:
		#update price label if its a one time purchase
		upgrade_4_price.text = "purchased"
	



func _on_button_pressed() -> void:
	if(upgrade_1_price_f * Game.discount <= Game.get_points()):
		Game.remove_time_points(upgrade_1_price_f * Game.discount)
		upgrade_1_price_f = Game.recalc_price(upgrade_1_price_f * Game.discount)
		upgrade_1_level += 1
		do_upgrade(upgrade_1_type)
		if(upgrade_1_type == Type.BASE_DATA):
			upgrade_1_button.disabled = true
			upgrade_1_price_f = -1
		update_price_labels()


func _on_button_pressed_2() -> void:
	if(upgrade_2_price_f * Game.discount <= Game.get_points()):
		Game.remove_time_points(upgrade_2_price_f * Game.discount)
		upgrade_2_price_f = Game.recalc_price(upgrade_2_price_f * Game.discount)
		upgrade_2_level += 1
		do_upgrade(upgrade_2_type)
		if(upgrade_2_type == Type.BASE_DATA):
			upgrade_2_button.disabled = true
			upgrade_2_price_f = -1
		update_price_labels()


func _on_button_pressed_3() -> void:
	if(upgrade_3_price_f * Game.discount <= Game.get_points()):
		Game.remove_time_points(upgrade_3_price_f * Game.discount)
		upgrade_3_price_f = Game.recalc_price(upgrade_3_price_f * Game.discount)
		do_upgrade(upgrade_3_type)
		if(upgrade_3_type == Type.BASE_DATA):
			upgrade_3_button.disabled = true
			upgrade_3_price_f = -1
		update_price_labels()


func _on_button_pressed_4() -> void:
	if(upgrade_4_price_f * Game.discount <= Game.get_points()):
		Game.remove_time_points(upgrade_4_price_f * Game.discount)
		upgrade_4_price_f = Game.recalc_price(upgrade_4_price_f * Game.discount)
		upgrade_4_level += 1
		do_upgrade(upgrade_4_type)
		if(upgrade_4_type == Type.BASE_DISCOUNT):
			upgrade_4_button.disabled = true
			upgrade_4_price_f = -1
		update_price_labels()
		
func do_upgrade(_upgrade_type:Type):
	match _upgrade_type:
		Type.MULTIPLIER:
			Game.add_base_mult(0.1)
		Type.BASE_LIVES:
			Game.add_life()
		Type.BASE_DATA:
			Game.doDataUpdate()
		Type.BASE_DISCOUNT:
			Game.doDiscountUpdate()
