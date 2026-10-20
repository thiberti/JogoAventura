extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -600.0

# Pega a gravidade definida nas configurações do projeto Godot
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Adiciona gravidade se o jogador estiver no ar
	if not is_on_floor():
		velocity.y += gravity * delta

	# Lógica de pulo (funciona com a tecla Espaço ou com o TouchScreenButton de pulo)
	if Input.is_action_just_pressed("pular") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Pega a direção da movimentação (-1 para esquerda, 1 para direita, 0 se nenhum for pressionado)
	var direction = Input.get_axis("mover_esquerda", "mover_direita")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
