extends Node

const PORT = 45982
const ADDRESS = "localhost"
const BROADCAST_PERIOD = 120

var socket = PacketPeerUDP.new()
var host_ip
var broadcast_wait = BROADCAST_PERIOD


func _ready():
	socket.listen(PORT + 1)


func _physics_process(_delta):
	if get_tree().is_network_server():
		broadcast_wait -= 1
		if broadcast_wait <= 0:
			broadcast_wait = BROADCAST_PERIOD
			socket.put_packet(PoolByteArray([0]))
	else:
		if socket.get_available_packet_count() > 0:
			socket.get_packet()
			var ip = socket.get_packet_ip()
			if host_ip != ip:
				host_ip = ip
				print("Found server %s" % ip)


remote func sync_tree(data: String):
	for child in $"/root/Main".get_children():
		if child.name.begins_with("Task"):
			child.free()
	$"/root/Main".load_tree(data)


func _host():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(PORT, 2)
	get_tree().network_peer = peer
	print("Created server with port %d" % PORT)
	
	socket.set_broadcast_enabled(true)
	socket.set_dest_address("255.255.255.255", PORT + 1)
	socket.put_packet(PoolByteArray([0]))


func _join():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(host_ip, PORT)
	get_tree().network_peer = peer
	print("Joined address \"%s\" with port %d" % [host_ip, PORT])


func _on_ButtonHost_pressed():
	_host()


func _on_ButtonConnect_pressed():
	_join()


func _on_ButtonSync_pressed():
	rpc("sync_tree", $"/root/Main/Task".surrender_data())
