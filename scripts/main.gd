extends Node2D

var moedas_coletadas = 0

# Referências dos nós da UI e do Player
@onready var texto_moedas = $UI/TextoMoedas
@onready var barra_vida = $UI/BarraVida
@onready var barra_mana = $UI/BarraMana
@onready var texto_vida = $UI/BarraVida/TextoStatus
@onready var texto_mana = $UI/BarraMana/TextoStatus
@onready var player = $Player

func _ready():
	# Conecta o sinal 'coletada' de todas as moedas
	for moeda in get_tree().get_nodes_in_group("moedas_grupo"):
		moeda.coletada.connect(_on_moeda_coletada)
		
	# Configura os valores máximos das barras na UI com base nos status do Player
	if player:
		barra_vida.max_value = player.vida_maxima
		barra_mana.max_value = player.mana_maxima

func _process(_delta):
	# Atualiza o valor visual das barras e os textos a cada quadro
	if player:
		barra_vida.value = player.vida_atual
		barra_mana.value = player.mana_atual
		
		# Exibe os números flat (arredondados para não mostrar casas decimais)
		texto_vida.text = str(int(player.vida_atual)) + " / " + str(int(player.vida_maxima))
		texto_mana.text = str(int(player.mana_atual)) + " / " + str(int(player.mana_maxima))

func _on_moeda_coletada():
	moedas_coletadas += 1
	texto_moedas.text = "Moedas: " + str(moedas_coletadas)
