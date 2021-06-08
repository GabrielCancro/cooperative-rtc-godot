extends Node

signal data_received(data)
signal change_players_data(players)
signal match_ready(players)
signal player_disconnected(id)

var gcnet_ws = preload("gcnet_websocket.gd").new()
var gcnet_rtc = preload("gcnet_webrtc.gd").new()

var ID
var PLAYERS={}
var HOST_CANDIDATE = -1
var MY_PLAYER_DATA


func _ready():
	gcnet_ws.set_rtc_ref(gcnet_rtc)
	gcnet_rtc.set_ws_ref(gcnet_ws)
	gcnet_ws.connect("have_id",self,"_ws_on_have_id")
	gcnet_ws.connect("change_players",self,"_ws_on_change_players_data")
	gcnet_ws.connect("players_ready",self,"_ws_on_players_ready")
	gcnet_rtc.connect("data_received",self,"_rtc_on_data_received")
	gcnet_rtc.connect("peer_disconnected",self,"_rtc_on_player_discconnected")
	pass

func find_match(match_code, player_data, url_ws_server):
	MY_PLAYER_DATA = player_data
	gcnet_ws.start_connection(match_code, player_data, url_ws_server)

func get_players_data():
	return PLAYERS

func get_id():
	return str(ID)

func send_message(data):
	gcnet_rtc.rtc_mp.put_packet(data.to_utf8())

func _process(delta):
	gcnet_ws.listen()
	gcnet_rtc.listen()

func _ws_on_have_id(new_id):
	ID = new_id

func _ws_on_rtc_config_received(data):
	gcnet_rtc.on_received_setup_message(data)

func _ws_on_change_players_data(players_data):
	PLAYERS = players_data
	HOST_CANDIDATE = players_data.keys()[0]
	emit_signal("change_players_data", players_data)

func _ws_on_players_ready(players_data):
	emit_signal("match_ready", players_data)

func _rtc_on_data_received(data):
	emit_signal("data_received", data)

func _rtc_on_player_discconnected(id):
	emit_signal("player_disconnected", id)
