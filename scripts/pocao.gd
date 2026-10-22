extends Area2D

@export_enum("Vida", "Mana") var tipo_pocao: String = "Vida"

func _on_body_entered(body):
	if body.name == "Player":
		if tipo_pocao == "Vida":
			DadosJogo.pocoes_vida += 1
		elif tipo_pocao == "Mana":
			DadosJogo.pocoes_mana += 1
			
		queue_free() # Some do mapa
