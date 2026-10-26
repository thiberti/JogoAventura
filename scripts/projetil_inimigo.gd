extends Area2D

var velocidade: float = 200.0
var direcao: float = 1.0
var dano: float = 10.0

func _process(delta):
	position.x += direcao * velocidade * delta

func _on_body_entered(body):
	# Aplica dano se atingir o Player
	if body.name == "Player" and body.has_method("tomar_dano"):
		body.tomar_dano(dano)
		queue_free()
	# Se bater em paredes/chão, se destrói
	elif body.name != "Inimigo" and not body.is_in_group("moedas_grupo"):
		queue_free()
