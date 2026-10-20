extends CharacterBody2D

# Configurações do Personagem e Classe
@export_enum("Geral", "Atirador", "Mago", "Assassino", "Lutador") var classe_personagem: String = "Geral"

# Atributos Modificáveis da Classe
var SPEED: float = 300.0
var JUMP_VELOCITY: float = -600.0

var vida_maxima: float = 100.0
var vida_atual: float = 100.0
var regen_vida: float = 1.0

var mana_maxima: float = 100.0
var mana_atual: float = 100.0
var regen_mana: float = 2.0

# Gravidade padrão do projeto
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Carregamento da Cena do projetil:
var cena_projetil = preload("res://scenes/projetil.tscn")

func _ready():
	# Configura os atributos conforme a classe definida
	aplicar_atributos_classe(classe_personagem)

func aplicar_atributos_classe(nome_classe: String):
	match nome_classe:
		"Atirador":
			SPEED = 350.0            # Mais ágil
			vida_maxima = 80.0       # Vida menor (glass cannon)
			mana_maxima = 120.0
			regen_vida = 1.0
			regen_mana = 3.0
		"Mago":
			SPEED = 280.0
			vida_maxima = 70.0
			mana_maxima = 250.0      # Muita mana
			regen_vida = 0.8
			regen_mana = 8.0         # Regeneração de mana rápida
		"Assassino":
			SPEED = 420.0            # Muito rápido
			vida_maxima = 90.0
			mana_maxima = 100.0
			regen_vida = 1.5
			regen_mana = 4.0
		"Lutador":
			SPEED = 260.0            # Mais lento
			vida_maxima = 180.0      # Muita vida (Tank)
			mana_maxima = 80.0
			regen_vida = 4.0         # Alta regeneração de vida
			regen_mana = 1.5
		_: # Caso seja "Geral" ou padrão
			SPEED = 300.0
			vida_maxima = 100.0
			mana_maxima = 100.0
			regen_vida = 1.0
			regen_mana = 2.0

	# Atualiza a vida e mana atuais para o novo máximo
	vida_atual = vida_maxima
	mana_atual = mana_maxima

func _physics_process(delta):
	# Gravidade
	if not is_on_floor():
		velocity.y += gravity * delta

	# Pulo
	if Input.is_action_just_pressed("pular") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movimento Horizontal
	var direction = Input.get_axis("mover_esquerda", "mover_direita")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	# Regeneração contínua
	regenerar_recursos(delta)

	# --- TESTES RÁPIDOS (J / K) ---
	if Input.is_key_pressed(KEY_J) or Input.is_physical_key_pressed(KEY_J):
		tomar_dano(20.0 * delta)
		
	if Input.is_key_pressed(KEY_K) or Input.is_physical_key_pressed(KEY_K):
		gastar_mana(30.0 * delta)
		
	# --- ATAQUE BÁSICO ---
	if Input.is_action_just_pressed("ui_accept"): # Tecla Espaço / Enter
		atacar()

func regenerar_recursos(delta):
	if vida_atual < vida_maxima:
		vida_atual = min(vida_atual + regen_vida * delta, vida_maxima)
		
	if mana_atual < mana_maxima:
		mana_atual = min(mana_atual + regen_mana * delta, mana_maxima)

func tomar_dano(quantidade: float):
	vida_atual = max(vida_atual - quantidade, 0.0)

func gastar_mana(quantidade: float):
	mana_atual = max(mana_atual - quantidade, 0.0)
	
	
func atacar():
	if classe_personagem in ["Atirador", "Mago"]:
		# Verifica se tem mana suficiente para atirar
		var custo_mana = 10.0 if classe_personagem == "Atirador" else 25.0
		if mana_atual >= custo_mana:
			gastar_mana(custo_mana)
			var proj = cena_projetil.instantiate()
			proj.position = global_position
			# Define a direção com base para onde o jogador está olhando (escala ou velocidade)
			proj.direcao = -1.0 if $Sprite2D.flip_h else 1.0 if has_node("Sprite2D") else 1.0
			get_parent().add_child(proj)
