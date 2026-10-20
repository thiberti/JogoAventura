extends Area2D

var velocidade: float = 600.0
var direcao: float = 1.0
var dano: float = 20.0

func _process(delta):
	position.x += velocidade * direcao * delta

func _on_body_entered(body):
	# Evita acertar o próprio jogador que atirou
	if body.name != "Player":
		# Se acertar um inimigo no futuro, aplica dano
		if body.has_method("tomar_dano"):
			body.tomar_dano(dano)
		queue_free() # Destrói o projétil
