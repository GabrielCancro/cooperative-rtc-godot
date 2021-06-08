extends Node2D

onready var Game = get_node("/root/Game")
var direction = Vector2(1,-1)
var velocity = 3

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(Game.HOST): _process_host()
	rotation += 0.1

func _process_host():
	position += direction.normalized() * velocity
	if(position.y<50): direction.y = 1
	if(position.y>550): direction.y = -1
	if(position.x<50): direction.x = 1
	if(position.x>550): direction.x = -1
	Game.action( { "code":"update_position", "target":"Enemies/"+name,"x":position.x, "y":position.y } )
	if( position.distance_to( Game.get_node("Player1").position ) < 15 ):
		Game.action( { "code":"hit_player", "target":"Player1" } )
	if( position.distance_to( Game.get_node("Player2").position ) < 15 ):
		Game.action( { "code":"hit_player", "target":"Player2" } )
