extends ColorRect

@onready var distractions_target = %distractions
@onready var shop_target = $MarginContainer/ScrollContainer/GridContainer

@onready var shop_item_template =  preload("res://scenes/shop_item.tscn")
@onready var _distraction_clicker = preload("res://scenes/distractions/distraction_clicker.tscn")
@onready var _distraction_pet = preload("res://scenes/distractions/distraction_pet.tscn")
@onready var _distraction_ticker = preload("res://scenes/distractions/distraction_ticker.tscn")
@onready var _distraction_timer_button = preload("res://scenes/distractions/distraction_timer_button.tscn")
@onready var _distraction_timer_suprise = preload("res://scenes/distractions/distraction_timer_suprise.tscn")

@onready var shop_items=[   _distraction_clicker,
							_distraction_pet,
							_distraction_ticker,
							_distraction_timer_button,
							_distraction_timer_suprise
						]



func _ready() -> void:
	for i in shop_items:
		var shop_item:ShopItem = shop_item_template.instantiate()
		shop_target.add_child(shop_item)#add shop item to shop
		
		var item:Distraction = i.instantiate()
		item.init()
		shop_item.set_title(item.title)
		shop_item.add_item(i)
		
		if(Game.is_new_game):
			shop_item.set_price(item.price)
		else:
			shop_item.tether()
		
		
		shop_item.bought.connect(_child_button_pressed)
	Game.game_loaded.emit()
		
		
func _child_button_pressed(packedscene: PackedScene):
	var distraction:Distraction = packedscene.instantiate()
	distraction.UI_MODE = false
	distraction.init()
	distraction.present_init_upgrade_data()
	distractions_target.add_child(distraction)
	print("bought " + str(distraction))
	
	
