extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Lobby/Button.connect("button_down",self,"on_button")
	Gcnet.connect("match_ready",self,"on_match_ready")
	pass # Replace with function body.

func on_button():
	Gcnet.find_match("_coopGame001_!#2", {}, "ws://godot-webrtc-server7000.herokuapp.com")
	$Lobby/Button.disabled = true
	$Lobby/Button.text = "buscando partida..."

func on_match_ready(_players):
	get_tree().change_scene("res://scenes/Game.tscn")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
