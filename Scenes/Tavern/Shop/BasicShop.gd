extends Control

var opened : bool = false

onready var root_node = get_tree().get_current_scene()
onready var game_data = root_node.find_node("GameData")
onready var elf = root_node.find_node("Elf")

onready var elf_stats = get_node("/root/World/ElfStats")

func _ready():
	game_data.connect("gold_changed", self, "on_Gold_changed")
	game_data.connect("xp_changed", self, "on_Xp_changed")
	
	for btn in get_children():
		btn.connect("bought", self, "disable_valid_buttons")
	
func on_Gold_changed():
	disable_valid_buttons()
	
func on_Xp_changed():
	disable_valid_buttons()
		
func disable_valid_buttons():
	for item in get_children():
		item.update_enabled()
