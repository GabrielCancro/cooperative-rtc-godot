extends Node

var ws = WebSocketClient.new()
signal have_id(id)
signal change_players(players)
signal players_ready(players)
signal rtc_config_received(data)

var gcnet_rtc
var ID
var PLAYERS = {}
var PEERS = {} #USE TO CHECK PLAYERS CONNECTIONS PEER-TO-PEER
var ENABLED = true
var MATCHCODE
var PLAYER_DATA

func _init():
	print("WS READY!")
	ws.connect('connection_established', self, '_connected')
	ws.connect('connection_closed', self, '_closed')
	ws.connect('connection_error', self, '_error')
	ws.connect('data_received', self, '_on_data')
	set_process(false)

func set_rtc_ref(_rtc_ref):
	gcnet_rtc = _rtc_ref

func start_connection(_matchCode, _player_data, _url_ws_server):
	set_process(true)
	MATCHCODE = _matchCode
	PLAYER_DATA = _player_data
	var err = ws.connect_to_url(_url_ws_server)
	if err != OK: print('connection refused')

func end_connection():
	ws.disconnect_from_host()

func _closed(err): print("websocket connection closed")

func _error(): print("connection error and close")

func _connected(protocol): 
	print("connected to host. PRT:"+protocol)
#	ws.get_peer(1).put_packet(JSON.print({"cmd":"hello", "nick":NICK}).to_utf8())
	
func _on_data():
	var ws_data=ws.get_peer(1).get_packet().get_string_from_utf8()
	var data = JSON.parse(ws_data).result
	print("<WS> "+str(data))
	if data["cmd"]=="yourId": 
		ID=data["id"]
		PLAYERS[ID] = true
		emit_signal("have_id",data["id"])
		send_data( {"cmd":"findMatch", "matchCode":MATCHCODE, "player_data":PLAYER_DATA})
	if data["cmd"]=="newPlayerAdded": 
		PLAYERS = data["match"]
		emit_signal("change_players", PLAYERS)
	if data["cmd"]=="playerExit": 
		PLAYERS = data["match"]
		emit_signal("change_players", PLAYERS) 
	if data["cmd"]=="offer" or data["cmd"]=="answer" or data["cmd"]=="candidate":		
		if data["id"]!=ID:
			gcnet_rtc.on_received_setup_message(data)
	if data["cmd"]=="startMatch":
		gcnet_rtc.initialize(ID)
		gcnet_rtc.connect("peer_connected", self, 'on_rtc_peer_connected')
		for player_id in PLAYERS:
			if (int(player_id) != ID):
				gcnet_rtc.create_peer( int(player_id) )

func on_rtc_peer_connected(id):
	PEERS[id] = true
	print("on_peer_connected")
	print(str(PEERS))
	if(PEERS.size()==PLAYERS.size()-1): 
		emit_signal("players_ready", PLAYERS)
		end_connection()
	
func send_data(data):
	print("<WS SEND> "+str(data))
	ws.get_peer(1).put_packet(JSON.print(data).to_utf8())

func listen():
	if !ENABLED: return
	ws.poll()
