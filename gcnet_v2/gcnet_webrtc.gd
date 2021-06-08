extends Node

signal data_received(data)
signal peer_connected(id)
signal peer_disconnected(id)

var rtc_mp : WebRTCMultiplayer 
var gcnet_ws
var MYID


func _init():
	rtc_mp = WebRTCMultiplayer.new()
	rtc_mp.connect("connection_failed", self, "_on_connection_failed")
	rtc_mp.connect("connection_succeeded", self, "_on_connection_succeeded")
	rtc_mp.connect("peer_connected", self, "_on_peer_connected")
	rtc_mp.connect("peer_disconnected", self, "_on_peer_disconnected")
	rtc_mp.connect("server_disconnected", self, "_on_server_disconnected")

func set_ws_ref(_ws_ref):
	gcnet_ws = _ws_ref
	
func initialize(id):
	MYID = id
	rtc_mp.initialize(id, false)

func listen():
	rtc_mp.poll()
	while rtc_mp.get_available_packet_count() > 0:
#		print("RTC available_message")
		var data = rtc_mp.get_packet()
		emit_signal("data_received", data.get_string_from_utf8())

func _on_connection_failed():
	print("RTC _on_connection_failed")

func _on_connection_succeeded():
	print("RTC _on_connection_succeeded")

func _on_peer_connected(id):
	print("RTC _on_peer_connected")
	emit_signal("peer_connected", id)

func _on_peer_disconnected(id):
	print("RTC _on_peer_disconnected")
	emit_signal("peer_disconnected", id)

func _on_server_disconnected():
	print("RTC _on_server_disconnected")

func create_peer(id):
	print("RTC Creating peer for ", id)
	var peer: WebRTCPeerConnection = WebRTCPeerConnection.new()
	peer.initialize({
		"iceServers": [ { "urls": ["stun:stun.l.google.com:19302"] } ]
	})
	peer.connect("session_description_created", self, "_offer_created", [id])
	peer.connect("ice_candidate_created", self, "_new_ice_candidate", [id])
	rtc_mp.add_peer(peer, id)
	if id > rtc_mp.get_unique_id():
		peer.create_offer()

func _new_ice_candidate(mid_name, index_name, sdp_name, id):
	send_candidate(id, mid_name, index_name, sdp_name)

func _offer_created(type, data, id):
	if not rtc_mp.has_peer(id):
		return
	print("created ", type)
	rtc_mp.get_peer(id).connection.set_local_description(type, data)
	if type == "offer": send_offer(id, data)
	else: send_answer(id, data)

func send_offer(id, offer):
	print("send_offer ")
	var data = {"cmd":"offer", "id":MYID, "offer_data":offer}
	gcnet_ws.send_data(data)

func send_answer(id, answer):
	print("send_answer ")
	var data = {"cmd":"answer", "id":MYID, "answer_data":answer}
	gcnet_ws.send_data(data)

func send_candidate(id, mid, index, sdp):
	print("send_candidate ")
	var candidate = {"mid":mid,"index":index,"sdp":sdp}
	var data = {"cmd":"candidate", "id":MYID, "candidate_data":candidate}
	gcnet_ws.send_data(data)

#on receiv setup message from WS
func on_received_setup_message(data):
	if not (data is Dictionary): return
	if (data["id"]==MYID): return
	if (data["cmd"]=="offer"):
		offer_received(data["id"], data["offer_data"])
	elif (data["cmd"]=="answer"):
		answer_received(data["id"], data["answer_data"])
	elif (data["cmd"]=="candidate"):
		candidate_received(data["id"], data["candidate_data"]["mid"], data["candidate_data"]["index"], data["candidate_data"]["sdp"])

func offer_received(id, offer):
	print("Got offer: %d" % id)
	if rtc_mp.has_peer(id):
		rtc_mp.get_peer(id).connection.set_remote_description("offer", offer)

func answer_received(id, answer):
	print("Got answer: %d" % id)
	if rtc_mp.has_peer(id):
		rtc_mp.get_peer(id).connection.set_remote_description("answer", answer)

func candidate_received(id, mid, index, sdp):
	print("candidate_received ")
	if rtc_mp.has_peer(id):
		rtc_mp.get_peer(id).connection.add_ice_candidate(mid, index, sdp)
