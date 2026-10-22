extends CharacterBody2D

#Cena da moeda
var cena_moeda = preload("res://scenes/moeda.tscn")

# Status do Inimigo
var vida_maxima: float = 50.0
var vida_atual: float = 50.0
var dano_contato: float = 15.0

# Movimento simples
var velocidade: float = 50.0
var direcao: float = 1.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	vida_atual = vida_maxima

func _physics_process(delta):
	# Aplica gravidade
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# Movimento básico para frente e para trás ao bater na parede
	velocity.x = direcao * velocidade
	move_and_slide()
	
	if is_on_wall():
		direcao *= -1.0 # Inverte a direção ao colidir

func tomar_dano(quantidade: float):
	vida_atual -= quantidade
	print("Inimigo recebeu dano! Vida restante: ", vida_atual)
	
	# Efeito visual simples ao tomar dano (pisca em branco/vermelho)
	if has_node("Sprite2D"):
		$Sprite2D.modulate = Color(2, 2, 2)
		await get_tree().create_timer(0.1).timeout
		$Sprite2D.modulate = Color(1, 0.3, 0.3)
		
	if vida_atual <= 0:
		derrotado()

func derrotado():
	# Instancia uma moeda na posição onde o inimigo morreu
	var moeda = cena_moeda.instantiate()
	moeda.position = global_position
	get_parent().add_child(moeda)
	
	# Garante que a moeda seja adicionada ao grupo para o main.gd se conectar
	moeda.add_to_group("moedas_grupo")
	
	# Destrói o inimigo
	queue_free()

func _on_area_dano_body_entered(body):
	# Aplica dano no jogador se ele encostar
	if body.name == "Player" and body.has_method("tomar_dano"):
		body.tomar_dano(dano_contato)
