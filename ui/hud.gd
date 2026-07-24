extends CanvasLayer

signal time_up

@export var tiempo_inicial: int = 300
@export var velocidad: float = 0.4 # Cada 0.4 s baja 1 unidad

var tiempo: int

@onready var timer = $Timer
@onready var timer_label = $Control/HBoxContainer/timer_label

func _ready():
	tiempo = tiempo_inicial
	timer.wait_time = velocidad
	actualizar_tiempo()
	timer.start()

func _on_timer_timeout():
	if tiempo > 0:
		tiempo -= 1
		actualizar_tiempo()
	else:
		timer.stop()
		emit_signal("time_up")

func actualizar_tiempo():
	timer_label.text = "TIME
	%03d" % tiempo
