extends CharacterBody2D

# Configurações do Inimigo
var vida_maxima: float = 50.0
var vida_atual: float = 50.0
var dano_contato: float = 15.0
var velocidade: float = 60.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Lógica de Perseguição
var alvo_player: Node2D = null

var cena_moeda = preload("res://scenes/moeda.tscn")

func _ready():
	vida_atual = vida_maxima

func _physics_process(delta):
	# Aplica gravidade
	if not is_on_floor():
		velocity.y += gravity * delta

	if alvo_player != null:
		# Persegue o jogador na horizontal
		var direcao_x = sign(alvo_player.global_position.x - global_position.x)
		velocity.x = direcao_x * velocidade
		
		# Inverte o sprite conforme a direção do movimento
		if has_node("Sprite2D") and direcao_x != 0:
			$Sprite2D.flip_h = (direcao_x < 0)
	else:
		# Parado ou patrulha básica se não estiver vendo o jogador
		velocity.x = move_toward(velocity.x, 0, velocidade)

	move_and_slide()

# --- Sinais da AreaVisao ---
func _on_area_visao_body_entered(body):
	if body.name == "Player":
		alvo_player = body

func _on_area_visao_body_exited(body):
	if body.name == "Player":
		alvo_player = null

# --- Receber Dano e Derrota ---
func tomar_dano(quantidade: float):
	vida_atual -= quantidade
	if has_node("Sprite2D"):
		$Sprite2D.modulate = Color(2, 2, 2)
		await get_tree().create_timer(0.1).timeout
		$Sprite2D.modulate = Color(1, 0.3, 0.3)
		
	if vida_atual <= 0:
		derrotado()

func derrotado():
	var moeda = cena_moeda.instantiate()
	moeda.position = global_position
	get_parent().add_child(moeda)
	moeda.add_to_group("moedas_grupo")
	queue_free()

func _on_area_dano_body_entered(body):
	if body.name == "Player" and body.has_method("tomar_dano"):
		body.tomar_dano(dano_contato)
