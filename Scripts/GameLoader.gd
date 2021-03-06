extends Node

signal save_data_was_loaded

const OFFLINE_LIMIT : bool = false
const OFFLINE_LIMIT_TIME : int = 7200 

const OFFLINE_BONUS_GOLD_RATIO : float = 0.3 

var level_manager
var elf

func setup() -> void:
	level_manager = get_parent().get_node("World").get_node("LevelManager")
	elf = get_parent().get_node("World").find_node("Elf")
	load_game()

func load_player_data():
	var save_dict = {}
	var nodes_to_save = get_tree().get_nodes_in_group('IHaveSthToSave')
	for node in nodes_to_save:
		save_dict[node.get_path()] = node.save()
	
	return save_dict

func load_game():
	var save_file = File.new()
	if not save_file.file_exists(GameSaver.SAVE_PATH):
		return

	save_file.open(GameSaver.SAVE_PATH, File.READ)
	var data = JSON.parse(save_file.get_as_text()).result;
	
	for node_path in data.keys():
		var node_data = data[node_path]
		for attribute in node_data:
			match attribute:	#Odczytywane są w kolejności alfabetycznej
				"__time":
					load_offline_time(int(node_data['__time']))
				"_golds_on_second":
					load_golds_on_second(float(node_data['_golds_on_second']))
				"_gold":
					load_gold_and_reward(float(node_data['_gold']), float(node_data['_golds_on_second']))
				"_silver_moon":
					load_silver_moon(int(node_data['_silver_moon']))
				"_hp":
					load_hp(float(node_data['_hp']))
				"_current_level":
					var current_level = int(node_data['_current_level'])
					load_level(current_level)
				"_elf_stats":
					load_elf_stats(node_data["_elf_stats"])
				"_health_potion":
					load_health_potion(node_data[attribute])
				"_price":
					load_price(float(node_data['_price']))
				"_dwarves_per_level":
					load_dwarves_per_level(int(node_data['_dwarves_per_level']))
				"_additional_gold_multipler":
					load_additional_gold_multipler(float(node_data['_additional_gold_multipler']))
				"_time_to_kill_boss":
					load_time_to_kill_boss(int(node_data['_time_to_kill_boss']))
				"_probability_to_get_silver_moon_in_percent":
					load_probability_to_get_silver_moon_in_percent(int(node_data['_probability_to_get_silver_moon_in_percent']))
				"_tradesman_item_price_multipler":
					load_tradesman_item_price_multipler(float(node_data['_tradesman_item_price_multipler']))
				"tavern_screen":
					load_tavern_data(node_data["tavern_screen"])
				
	emit_signal("save_data_was_loaded")

func load_offline_time(time):
	var offline_time = OS.get_unix_time() - time
	if OFFLINE_LIMIT:
		if offline_time > OFFLINE_LIMIT_TIME:
			offline_time = OFFLINE_LIMIT_TIME
	GameData.offline_time = offline_time

func load_golds_on_second(gold_on_second):
	GameData.golds_on_second = gold_on_second

func load_gold_and_reward(gold, gold_on_second):
	GameData.offline_gold_reward = gold_on_second * OFFLINE_BONUS_GOLD_RATIO * GameData.offline_time
	GameData.gold = gold + GameData.offline_gold_reward

func load_silver_moon(silver_moon):
	GameData.silver_moon = silver_moon

func load_hp(hp):
	elf.set_current_hp(hp)

func load_level(level):
	level_manager.set_level(level)

func load_elf_stats(elf_stats):
	ElfStats.load_data(elf_stats)
	elf.reset_to_base()

func load_health_potion(health_potion):
	var potions = get_tree().get_root().get_node("World").find_node("HealthPotion")
	potions.set_amount(health_potion)
	if(potions.amount <= 0):
		potions.hide()
	else:
		potions.show()

func load_price(price):
	var items = get_parent().find_node("Items") 
	for item in items.get_children():
		item.find_node("*BuyBtn").set_disabled(price > GameData.gold)
		
		# TODO What is this?:
		var ArrowDmgItem = get_parent().find_node("ArrowDmgItem")
		ArrowDmgItem.price = price
		ArrowDmgItem.update_price_label()

func load_dwarves_per_level(count):
	level_manager.dwarves_per_level = count

func load_additional_gold_multipler(value):
	GameData.additional_gold_multipler = value

func load_time_to_kill_boss(time):
	GameData.time_to_kill_boss = time

func load_probability_to_get_silver_moon_in_percent(value):
	GameData.probability_to_get_silver_moon_in_percent = value

func load_tradesman_item_price_multipler(value):
	GameData.tradesman_item_price_multipler = value

func load_gold(gold):
	GameData.gold = gold

func load_tavern_data(data) -> void:
	var tavern = get_parent().get_node("World").find_node("TavernScreen")
	tavern.load_data(data)
	
func revival_reset():
	ElfStats.restore_to_default()
	load_offline_time(0)
	load_golds_on_second(0.0)
	load_gold(0.0)
	load_hp(ElfStats.get_stat_value("vitality"))
	load_level(1)
	load_health_potion(0)
