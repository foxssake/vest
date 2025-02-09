extends Node

func _ready():
	var port := VestEditorPlugin._get_debug_port()
	port = 51372
	print("Running client with debug port %d" % [port])

	var client := VestRemoteClient.new()
	add_child(client)
	await client.connect_to_host(port)
	await client.poll_commands()
	client.disconnect_from_host()

	get_tree().quit()
