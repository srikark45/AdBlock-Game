extends Area2D

signal stomped

func receive_stomp():
	emit_signal("stomped")
	# this signal is temporarily connected to "queue_free"
	# but the parent should do this, once we have one.
