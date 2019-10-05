extends Node2D

export(float) var dwarf_max_hp : float = 10.0
export(float) var dwarf_damage : float = 1.0
export(float) var boss_max_hp : float = 40.0
export(float) var boss_damage : float = 3.0
export(bool) var spawn : bool = true

var Dwarf = load("res://Objects/Dwarves/Dwarf/Dwarf.tscn")
var Boss = load("res://Objects/Dwarves/Boss/Boss.tscn")
var Tavern = load("res://Objects/Tavern/Tavern.tscn")
var Devil = load("res://Objects/Devil/Devil.tscn")

onready var base_dwarf_hp = dwarf_max_hp
onready var base_dwarf_damage = dwarf_damage

onready var world = get_parent()
onready var level_manager = world.get_node("LevelManager")

var total_dwarves_kill_counter : int = 0

func _ready():
	yield(get_tree().create_timer(1.0), "timeout")
	spawn_dwarf()

func spawn_dwarf():
	if spawn:
		create_dwarf(Dwarf, dwarf_damage, dwarf_max_hp, "on_Dwarf_died")
	
func spawn_boss():
	if spawn:
		var boss = create_dwarf(Boss, boss_damage, boss_max_hp, "on_Boss_died")
		boss.connect("boss_kill_timeout", level_manager, "on_Boss_kill_timeout")
	
func spawn_tavern():
	var tavern = Tavern.instance()
	world.call_deferred("add_child", tavern)
	tavern.global_position = global_position
	spawn = false

func spawn_devil():
	var devil = Devil.instance()
	world.call_deferred("add_child", devil)
	devil.global_position = global_position
	spawn = false

func create_dwarf(DwarfScene, damage:float, hp:float, on_died_func:String):
	var dwarf = DwarfScene.instance()
	call_deferred("add_child", dwarf)
	dwarf.damage = damage
	dwarf.set_hp(hp)
	dwarf.connect("died", level_manager, on_died_func)
	dwarf.connect("died", self, "_on_Dwarf_died")
	return dwarf
	
func on_next_level(level : int):
	dwarf_max_hp += dwarf_max_hp * level * 0.1
	dwarf_damage += level * 0.1
	
	if (level-1) % 10 == 0:
		base_dwarf_hp = dwarf_max_hp
		base_dwarf_damage = dwarf_damage
		
func reset_to_base():
	reset_dwarf_data()

func reset_dwarf_data():
	dwarf_max_hp = base_dwarf_hp
	dwarf_damage = base_dwarf_damage
	
func _on_Dwarf_died():
	total_dwarves_kill_counter += 1
	
func remove_all_dwarves():
	for dwarf in get_children():
		dwarf.queue_free()