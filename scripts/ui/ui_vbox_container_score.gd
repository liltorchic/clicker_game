extends VBoxContainer


var lives_label_data:Label
var score_label_data:Label
var mult_label_data:Label
var label100kp_data:Label
var discount_data:Label
var container_100k:HBoxContainer
var container_discount:HBoxContainer

@onready var shop_window_target = $"../../../../shop"

func _on_button_pressed() -> void:
	shop_window_target.visible = true 


func _on_button_back_pressed() -> void:
	shop_window_target.visible = false

func _ready() -> void:
	lives_label_data = get_node("container_lives_hor/Label_Lives_num")
	lives_label_data.text = ""
	score_label_data = get_node("container_points_hor/Label_Points_num")
	score_label_data.text = ""
	mult_label_data = get_node("container_mult_hor/Label_Multiplier")
	mult_label_data.text = ""
	label100kp_data = get_node("container_100kp_extra/Label_100kp_data")
	label100kp_data.text = ""
	discount_data = get_node("container_discount_extra/Label_discount_data")
	discount_data.text = ""
	container_100k = get_node("container_100kp_extra")
	container_discount = get_node("container_discount_extra")
	
	
	Game.data_purchased.connect(_data_purchased)
	
func _process(delta: float) -> void:
	if(str(Game.lives) != lives_label_data.text):
		lives_label_data.text = str(Game.lives)
		
	if(str(Game.time_points) != score_label_data.text):
		score_label_data.text = str("%.3f" % [Game.time_points])
		
	if(Game.isMultUnlocked):
		if(str(Game.get_multiplier()) != mult_label_data.text):
			mult_label_data.text = "x" + str(Game.get_multiplier())
	else:
		mult_label_data.text = ""
		
	if(str(Game.hundredkprogess) != label100kp_data.text):
		label100kp_data.text = str(Game.hundredkprogess)
	
	if(str(Game.discount) != discount_data.text):
		discount_data.text = str(Game.discount)

func _data_purchased():
	container_100k.visible = true
	container_discount.visible = true
