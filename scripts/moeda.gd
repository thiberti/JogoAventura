extends Area2D

# Sinal emitido ao coletar a moeda
signal coletada

func _on_body_entered(body):
	# Verifica se quem encostou na moeda foi o Player
	if body.name == "Player":
		coletada.emit() # Envia o sinal de coleta
		queue_free()   # Destrói a moeda da cena
