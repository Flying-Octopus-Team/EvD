extends Control

var opened : bool = false

onready var root_node = get_tree().get_current_scene()
onready var game_data = root_node.find_node("GameData")
onready var elf = root_node.find_node("Elf")

func _ready():
	game_data.connect("gold_changed", self, "on_Gold_changed")
	game_data.connect("xp_changed", self, "on_Xp_changed")
	
func on_Gold_changed():
	disable_valid_buttons()
	
func on_Xp_changed():
	disable_valid_buttons()
		
func disable_valid_buttons():
	for i in range(get_child_count()):
		var item = get_child(i)	
		var price = float(item.get_node("Price").text)
		match item.price_type:
			item.PriceType.GOLD:
				item.find_node("BuyBtn").set_disabled(price > game_data.gold)
			item.PriceType.XP:
				item.find_node("BuyBtn").set_disabled(price > game_data.xp)
