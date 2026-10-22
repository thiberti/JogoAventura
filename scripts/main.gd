extends Node2D

var moedas_coletadas = 0

# Referências dos nós da UI e do Player
@onready var texto_moedas = $UI/TextoMoedas
@onready var barra_vida = $UI/BarraVida
@onready var barra_mana = $UI/BarraMana
@onready var texto_vida = $UI/BarraVida/TextoStatus
@onready var texto_mana = $UI/BarraMana/TextoStatus
@onready var player = $Player
@onready var texto_pocao_vida = $UI/TextoPocaoVida
@onready var texto_pocao_mana = $UI/TextoPocaoMana

func _ready():
	# Conecta as moedas já existentes no mapa no início
	conectar_moedas_existentes()
	
	# Escuta quando novos nós são adicionados na cena (para conectar moedas dropadas por inimigos)
	child_entered_tree.connect(_on_child_entered_tree)
		
	# Configura os valores máximos das barras na UI com base nos status do Player
	if player:
		barra_vida.max_value = player.vida_maxima
		barra_mana.max_value = player.mana_maxima

func _process(_delta):
	# Atualiza o valor visual das barras e os textos a cada quadro
	if player:
		barra_vida.value = player.vida_atual
		barra_mana.value = player.mana_atual
		
		# Exibe os números flat
		texto_vida.text = str(int(player.vida_atual)) + " / " + str(int(player.vida_maxima))
		texto_mana.text = str(int(player.mana_atual)) + " / " + str(int(player.mana_maxima))
	if texto_pocao_vida and texto_pocao_mana:
		texto_pocao_vida.text = "[1] HP: " + str(DadosJogo.pocoes_vida)
		texto_pocao_mana.text = "[2] MP: " + str(DadosJogo.pocoes_mana)

func conectar_moedas_existentes():
	for moeda in get_tree().get_nodes_in_group("moedas_grupo"):
		if not moeda.coletada.is_connected(_on_moeda_coletada):
			moeda.coletada.connect(_on_moeda_coletada)

func _on_child_entered_tree(node):
	# Se um novo nó adicionado ao mapa for uma moeda, conecta o sinal dela
	if node.is_in_group("moedas_grupo"):
		if not node.coletada.is_connected(_on_moeda_coletada):
			node.coletada.connect(_on_moeda_coletada)

func _on_moeda_coletada():
	moedas_coletadas += 1
	texto_moedas.text = "Moedas: " + str(moedas_coletadas)
	
