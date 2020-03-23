extends KinematicBody2D

const CIMA = Vector2.UP
const GRAVIDADE = 1700.0
const VELOCIDADE = 200.0
const FORCA_PULO = -750.0
const FORCA_DESLIZAR_PADRAO = 300.0

var movimento = Vector2()
var pulando = false
var agachado = false
var forca_deslizar = FORCA_DESLIZAR_PADRAO

var CHICOTE = preload("res://src/Objects/Chicote/Chicote.tscn")
var chicote

func _physics_process(delta):

	movimento.y += GRAVIDADE * delta
	if Input.is_action_pressed("agachar") and Input.is_action_pressed("mover_direita") and !pulando:
		$PlayerSprite.flip_h = false
		$PlayerShape.scale = Vector2(1, 0.5)
		$PlayerSprite.play("Agachando")
		
		movimento.x = VELOCIDADE + forca_deslizar
		if movimento.x >= 0.0:
			forca_deslizar -= 10
	elif Input.is_action_pressed("agachar") and Input.is_action_pressed("mover_esquerda") and !pulando:
		$PlayerSprite.flip_h = true
		$PlayerShape.scale = Vector2(1, 0.5)
		$PlayerSprite.play("Agachando")
		
		movimento.x = -VELOCIDADE - forca_deslizar
		if movimento.x <= 0.0:
			forca_deslizar -= 10
	elif Input.is_action_pressed("mover_direita"):
		$PlayerSprite.flip_h = false
		$PlayerShape.scale = Vector2(1, 1)
		if pulando == false:
			$PlayerSprite.play("Correndo")
		
		movimento.x = VELOCIDADE
		forca_deslizar = FORCA_DESLIZAR_PADRAO
		if sign($Position2D.position.x) == -1:
			$Position2D.position.x *= -1
	elif Input.is_action_pressed("mover_esquerda"):
		$PlayerSprite.flip_h = true
		$PlayerShape.scale = Vector2(1, 1)
		if pulando == false:
			$PlayerSprite.play("Correndo")
		
		movimento.x = -VELOCIDADE
		forca_deslizar = FORCA_DESLIZAR_PADRAO
		if sign($Position2D.position.x) == 1:
			$Position2D.position.x *= -1
	elif Input.is_action_pressed("agachar"):
		movimento.x = 0.0
		
		$PlayerSprite.play("Agachando")
		$PlayerShape.scale = Vector2(1, 0.5)
		agachado = true
		forca_deslizar = FORCA_DESLIZAR_PADRAO
	elif Input.is_action_pressed("chicotear"):
		$PlayerSprite.play("Chicoteando")
		if is_on_floor():
			movimento.x = 0.0
		chicote = CHICOTE.instance()
		get_parent().get_parent().add_child(chicote)
		chicote.global_position = $Position2D.global_position
		if sign($Position2D.position.x) == -1:
			chicote.mudar_direcao()
		
	else:
		forca_deslizar = FORCA_DESLIZAR_PADRAO
		movimento.x = 0.0
		if pulando == false:
			$PlayerSprite.play("Parado")
			$PlayerShape.scale = Vector2(1, 1)
		
		
	if is_on_floor():
		if Input.is_action_pressed("pular"):
			$PlayerSprite.play("Pulando")
			movimento.y = FORCA_PULO
			pulando = true
		else:
			pulando = false
		
		
	movimento = move_and_slide(movimento, CIMA)

func reiniciar_fase():
	get_tree().reload_current_scene()

func morrer():
	$PlayerSprite.play("Morrendo")
	set_physics_process(false)
	get_tree().get_nodes_in_group("cronometro")[0].stop()
	get_parent().reduzir_um_seg_cronometro()
	get_parent().mudar_texto("Você morreu.")
	$Reiniciar_a_fase.start()

func _on_Timer_timeout():
	morrer()

func _on_Reiniciar_a_fase_timeout():
	reiniciar_fase()
