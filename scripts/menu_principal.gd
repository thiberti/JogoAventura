extends Control

func _ready():
	# Conecta o clique de cada botão para selecionar a classe e carregar o jogo
	$VBoxContainer/BtnAtirador.pressed.connect(func(): selecionar_classe("Atirador"))
	$VBoxContainer/BtnMago.pressed.connect(func(): selecionar_classe("Mago"))
	$VBoxContainer/BtnAssassino.pressed.connect(func(): selecionar_classe("Assassino"))
	$VBoxContainer/BtnLutador.pressed.connect(func(): selecionar_classe("Lutador"))

func selecionar_classe(nome_classe: String):
	# Salva a classe no script global
	DadosJogo.classe_selecionada = nome_classe
	# Carrega a cena principal do jogo
	get_tree().change_scene_to_file("res://scenes/main.tscn")
