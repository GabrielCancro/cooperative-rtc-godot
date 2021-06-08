extends Node2D

onready var Game = get_node("/root/Game")
var time_delta = 0
var velocity = 5
var IM = false

func _ready():
	yield(get_tree().create_timer(0.1), "timeout")
	if Game.HOST and name == "Player1": IM = true
	if !Game.HOST and name == "Player2": IM = true
	if IM: Game.get_node("Info").text += "  "+name+".."+str(Gcnet.ID)
	if IM and Game.HOST: Game.get_node("Info").text += "  HOST"
	print("IM PLAYER!! "+str(Gcnet.ID))

func _process(delta):
	if IM: process_inputs()
	if modulate.a < 1: modulate.a += 0.02

func process_inputs():
	var move = Vector2()
	if Input.is_action_pressed("ui_up"): move.y = -1
	if Input.is_action_pressed("ui_right"): move.x = 1
	if Input.is_action_pressed("ui_down"): move.y = 1
	if Input.is_action_pressed("ui_left"): move.x = -1
	if move.length() != 0:
		position += move.normalized()*velocity
		Game.action( { "code":"update_position", "target":name,"x":position.x, "y":position.y } )

func hit():
	if modulate.a > 0.8: modulate.a = 0.2
