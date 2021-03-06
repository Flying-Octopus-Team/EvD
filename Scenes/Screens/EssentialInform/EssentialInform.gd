extends CanvasLayer

signal timeout

onready var top_text_label = get_node("Control/MarginContainer/VBoxContainer/TopText")
onready var icon_sprite = get_node("Sprite")
onready var center_text_label = get_node("Control/MarginContainer/VBoxContainer/CenterText")
onready var game_manager = get_parent().get_node("GameManager")

var top_text: String = ""
var center_text: String = ""
var icon_anim_name = "moon"
var fade_in_anim : String
var fade_out_anim : String

var time_to_left: float = 0
var timeout_resume_game: bool = false

onready var anim = get_node("AnimationPlayer")

func init(Time_to_left = 0, Top_text : String = "", Center_text : String = "", Icon_anim_name: String = "skull", Timeout_resume_game: bool = true, fade_in_anim: String = "FadedIn", fade_out_anim: String = "FadedOut"):
	time_to_left = Time_to_left
	top_text = Top_text
	center_text = Center_text
	icon_anim_name = Icon_anim_name
	timeout_resume_game = Timeout_resume_game
	self.fade_in_anim = fade_in_anim
	self.fade_out_anim = fade_out_anim

func _ready():
	game_manager.stop_gameplay();
	anim.play(fade_in_anim)
	top_text_label.text = top_text
	center_text_label.text = center_text
	icon_sprite.play(icon_anim_name)

func _on_ExitButton_pressed():
	anim.play(fade_out_anim)
	emit_signal("timeout")
	get_parent().find_node("TavernScreen").enter_tavern()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == fade_out_anim:
		if timeout_resume_game:
			game_manager.resume_gameplay();
		exit()

func exit():
	queue_free()
