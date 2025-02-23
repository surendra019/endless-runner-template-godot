extends Area3D

func _ready() -> void:
	body_entered.connect(func(body: Node3D):
		if body.name == "Player":
			get_tree().get_first_node_in_group("main").game_over()
		
		)
