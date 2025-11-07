extends Node2D
const GRID_SIZE = 20
const CELL_SIZE = 20
const GAME_DURATION = 30.0
var speed = 0.12  # snake move interval (lower = faster)
const GRID_OFFSET = Vector2(-400, 00)  # move up by 50 pixels (adjust as needed)

var snake = [Vector2(5,5)]
var direction = Vector2(1,0)
var food = Vector2(10,5)
var timer = 0.0
var game_time = 0.0
var score = 0
var paused = false
var game_over = false

@onready var score_label = $ScoreLabel
@onready var timer_label = $TimerLabel
@onready var restart_button = $RestartButton
@onready var pause_button = $PauseButton

func _ready():
	_spawn_food()
	restart_button.pressed.connect(_restart_game)
	pause_button.pressed.connect(_toggle_pause)
	_update_ui()

func _process(delta):
	if not paused and not game_over:
		timer += delta
		game_time += delta
		if timer >= speed:
			timer = 0
			_move_snake()
		if game_time >= GAME_DURATION:
			game_over = true
			
	_update_ui()
	queue_redraw()  # always redraw snake, food, border

func _input(event):
	if paused or game_over:
		return
	if event.is_action_pressed("ui_up") and direction != Vector2(0,1): direction = Vector2(0,-1)
	elif event.is_action_pressed("ui_down") and direction != Vector2(0,-1): direction = Vector2(0,1)
	elif event.is_action_pressed("ui_left") and direction != Vector2(1,0): direction = Vector2(-1,0)
	elif event.is_action_pressed("ui_right") and direction != Vector2(-1,0): direction = Vector2(1,0)
	
	if event.is_action_pressed("restart"): # Restart using Space key, works anytime
		_restart_game()

func _move_snake():
	var head = snake[0] + direction
	if head in snake or head.x<0 or head.y<0 or head.x>=GRID_SIZE or head.y>=GRID_SIZE:
		game_over = true
		return
	snake.insert(0, head)
	if head == food:
		score += 1
		_spawn_food()
	else:
		snake.pop_back()

func _spawn_food():
	var rng = RandomNumberGenerator.new()
	food = Vector2(rng.randi_range(0, GRID_SIZE-1), rng.randi_range(0, GRID_SIZE-1))
	while food in snake:
		food = Vector2(rng.randi_range(0, GRID_SIZE-1), rng.randi_range(0, GRID_SIZE-1))

func _restart_game():
	snake = [Vector2(5,5)]
	direction = Vector2(1,0)
	timer = 0
	game_time = 0
	score = 0
	game_over = false
	paused = false
	_spawn_food()
	queue_redraw()

func _toggle_pause():
	paused = not paused

func _update_ui():
	score_label.text = "Score: %d" % score
	timer_label.text = "Time: %.1f" % max(GAME_DURATION - game_time,0)
	pause_button.text = "Resume" if paused else "Pause"

func _draw():
	var viewport_size = get_viewport_rect().size
	var grid_size = Vector2(GRID_SIZE, GRID_SIZE) * CELL_SIZE
	var offset = ((viewport_size - grid_size) / 2).floor() + GRID_OFFSET  # apply manual shift

	for s in snake:
		draw_rect(Rect2(offset + s * CELL_SIZE, Vector2(CELL_SIZE, CELL_SIZE)), Color(1, 0.84, 0, 1.0))# snake
		draw_rect(Rect2(offset + food * CELL_SIZE, Vector2(CELL_SIZE, CELL_SIZE)), Color(1.0, 0.6, 0.2, 1.0))   # food
		draw_rect(Rect2(offset, grid_size), Color(0.376, 0.891, 0.902, 4.0), false, 5)                              	# border
