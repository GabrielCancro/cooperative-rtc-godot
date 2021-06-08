extends Node2D

onready var HOST = (Gcnet.HOST_CANDIDATE == str(Gcnet.ID))
var GAME_DATA = {}
var time_delta = 0.0

func _ready():
	Gcnet.connect("data_received",self,"_on_message")
	pass # Replace with function body.

func _process(delta):
	time_delta += delta
	if time_delta < 0.1: return
	else: time_delta -= 0.1

func action(config):
	config["id"] = Gcnet.ID
	if HOST: _run_action(config)
	var data = JSON.print(config)
	Gcnet.send_message(data)

func _run_action(config):
	if config["code"] == "update_position":
		get_node(config.target).position = Vector2(config.x,config.y)
	if config["code"] == "hit_player":
		get_node(config.target).hit()
	if config["code"] == "instance_enemy":
		get_node(config.target).instance()

func _on_message(data):
	print("_on_message")
	var config = JSON.parse(data).result
	_run_action(config)
