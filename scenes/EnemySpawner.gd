extends Node2D

const enemy_scene = preload("res://scenes/Game/Enemy.tscn")

onready var Game = get_node("/root/Game")

func _ready():
	yield(get_tree().create_timer(1.5), "timeout")
	if Game.HOST: Game.action( { "code":"instance_enemy","target":name } )
	yield(get_tree().create_timer(1.5), "timeout")
	if Game.HOST: Game.action( { "code":"instance_enemy","target":name } )
	yield(get_tree().create_timer(1.5), "timeout")
	if Game.HOST: Game.action( { "code":"instance_enemy","target":name } )

func instance():
	var GO = enemy_scene.instance()
	GO.name = "Enemy"
	GO.position = position
	Game.get_node("Enemies").add_child(GO)
