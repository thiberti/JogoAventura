extends CharacterBody2D

# Configurações do Personagem e Classe
@export_enum("Geral", "Atirador", "Mago", "Assassino", "Lutador") var classe_personagem: String = "Geral"

# Atributos Modificáveis da Classe
var SPEED: float = 300.0
var JUMP_VELOCITY: float = -700.0

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
	# Verifica se a variável global DadosJogo existe na cena e pega a classe escolhida
	if get_node_or_null("/root/DadosJogo"):
		classe_personagem = DadosJogo.classe_selecionada
		
	# Aplica os atributos da classe selecionada
	aplicar_atributos_classe(classe_personagem)

func aplicar_atributos_classe(nome_classe: String):
	match nome_classe:
		"Atirador":
			SPEED = 350.0            # Mais ágil
			vida_maxima = 80.0       # Vida menor (glass cannon)
			mana_maxima = 120.0
			regen_vida = 0.5
			regen_mana = 3.0
		"Mago":
			SPEED = 280.0
			vida_maxima = 70.0
			mana_maxima = 250.0      # Muita mana
			regen_vida = 0.8
			regen_mana = 8.0         # Regeneração de mana rápida
		"Assassino":
			SPEED = 500.0            # Muito rápido
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
		# Vira o Sprite para o lado correto do movimento
		if has_node("Sprite2D"):
			$Sprite2D.flip_h = (direction < 0)
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
		
# Dentro do _physics_process(delta):
	# Atalhos para usar poções do inventário
	if Input.is_key_pressed(KEY_1) or Input.is_physical_key_pressed(KEY_1):
		usar_pocao_vida()
		
	if Input.is_key_pressed(KEY_2) or Input.is_physical_key_pressed(KEY_2):
		usar_pocao_mana()

func usar_pocao_vida():
	if DadosJogo.pocoes_vida > 0 and vida_atual < vida_maxima:
		DadosJogo.pocoes_vida -= 1
		vida_atual = min(vida_atual + 40.0, vida_maxima)

func usar_pocao_mana():
	if DadosJogo.pocoes_mana > 0 and mana_atual < mana_maxima:
		DadosJogo.pocoes_mana -= 1
		mana_atual = min(mana_atual + 40.0, mana_maxima)

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
	# Ataque à Distância (Atirador / Mago)
	if classe_personagem in ["Atirador", "Mago"]:
		var custo_mana = 10.0 if classe_personagem == "Atirador" else 25.0
		
		# Verifica se o jogador tem mana suficiente
		if mana_atual >= custo_mana:
			gastar_mana(custo_mana) # Dedução de mana garantida
			
			var proj = cena_projetil.instantiate()
			proj.position = global_position
			
			# Direção do disparo conforme o olhar do jogador
			if has_node("Sprite2D") and $Sprite2D.flip_h:
				proj.direcao = -1.0
			else:
				proj.direcao = 1.0
				
			get_parent().add_child(proj)
			
	# Ataque Corpo a Corpo (Assassino / Lutador)
	elif classe_personagem in ["Assassino", "Lutador"]:
		var custo_mana = 15.0 if classe_personagem == "Assassino" else 5.0
		if mana_atual >= custo_mana:
			gastar_mana(custo_mana)
			executar_ataque_melee()

func executar_ataque_melee():
	# Inverte a posição do nó da AreaAtaque e o sprite do ataque
	if has_node("Sprite2D") and $Sprite2D.flip_h:
		$AreaAtaque.position.x = -abs($AreaAtaque.position.x)
		if has_node("AreaAtaque/Sprite2D"):
			$AreaAtaque/Sprite2D.flip_h = true
	else:
		$AreaAtaque.position.x = abs($AreaAtaque.position.x)
		if has_node("AreaAtaque/Sprite2D"):
			$AreaAtaque/Sprite2D.flip_h = false
		
	# Ativa colisão e exibe o sprite de ataque
	$AreaAtaque.monitoring = true
	if has_node("AreaAtaque/Sprite2D"):
		$AreaAtaque/Sprite2D.visible = true
	
	# Janela do golpe (0.2s)
	await get_tree().create_timer(0.2).timeout
	
	# Desativa colisão e oculta o sprite
	$AreaAtaque.monitoring = false
	if has_node("AreaAtaque/Sprite2D"):
		$AreaAtaque/Sprite2D.visible = false

# Função acionada quando a AreaAtaque acerta algo enquanto estiver ligada
func _on_area_ataque_body_entered(body):
	if body.name != "Player" and body.has_method("tomar_dano"):
		# Define o dano com base na classe
		var dano_melee = 35.0 if classe_personagem == "Assassino" else 25.0
		body.tomar_dano(dano_melee)
