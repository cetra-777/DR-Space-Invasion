# frozen_string_literal: true

def defaults(args)
  args.state.fps ||= 60

  if args.state.tick_count == 1
    args.audio[:music] =
      { input: 'sounds/SpaceShooterBgMusic.ogg', gain: 0.7, looping: true }
  end

  # Game State 1: Main Menu
  # Game State 2: Game Playing
  # Game State 3: Game Over
  args.state.game_state ||= 1

  # Create Background
  args.state.bg1 ||= { x: 0, y: 0, w: args.grid.w, h: args.grid.h, path: 'sprites/starfield2.png' }
  args.state.bg2 ||= { x: 0, y: args.grid.h, w: args.grid.w, h: args.grid.h, path: 'sprites/starfield2.png' }
  args.state.bg_speed ||= 1

  # Create Player
  args.state.player ||= {
    x: args.grid.w / 2 - 32,
    y: 50,
    w: 64,
    h: 64,
    speed: 10,
    path: 'sprites/player.png'
  }

  # Create player laser container
  args.state.player_lasers ||= []

  # Create player fire timer
  args.state.player_fire_timer ||= 0

  # Create player score
  args.state.score ||= 0

  # Create last score
  args.state.last_score ||= 0

  # Create last score label
  args.state.last_score_label = { x: args.grid.w * 0.05, y: args.grid.h * 0.8, text: "Prev. Score:  #{args.state.last_score}",
                                  size_enum: 2,
                                  alignment_enum: 0,
                                  r: 255,
                                  g: 255,
                                  b: 255,
                                  font: 'fonts/Gbboot-ALpM.ttf' }

  # Create score label
  args.state.score_label = { x: args.grid.w * 0.05, y: args.grid.h * 0.9, text: "Score:  #{args.state.score}",
                             size_enum: 10,
                             alignment_enum: 0,
                             r: 255,
                             g: 255,
                             b: 255,
                             font: 'fonts/Gbboot-ALpM.ttf' }

  # Create instructions labels
  args.state.insturctions_label = { x: args.grid.w / 2, y: args.grid.h / 2 + 20, text: 'Press any key or button to play',
                                    size_enum: 15,
                                    alignment_enum: 1,
                                    r: 255,
                                    g: 255,
                                    b: 255,
                                    font: 'fonts/Gbboot-ALpM.ttf' }

  args.state.insturctions_label2 = { x: args.grid.w / 2, y: args.grid.h / 2 - 80, text: 'Use the A button or Z/J keys to fire',
                                     size_enum: 10,
                                     alignment_enum: 1,
                                     r: 255,
                                     g: 255,
                                     b: 255,
                                     font: 'fonts/Gbboot-ALpM.ttf' }

  # Create Play again label
  args.state.play_again_label = { x: args.grid.w / 2, y: args.grid.h / 2 + 20, text: 'Press any key to play again',
                                  size_enum: 15,
                                  alignment_enum: 1,
                                  r: 255,
                                  g: 255,
                                  b: 255,
                                  font: 'fonts/Gbboot-ALpM.ttf' }

  # Create enemy1 bank
  args.state.enemy1s ||= [
    spawn_enemy_type_one(args),
    spawn_enemy_type_one(args),
    spawn_enemy_type_one(args)
  ]

  # Create enemy1 laser container
  args.state.enemy_type_one_lasers ||= []

  # Create enemy1 fire timer
  args.state.enemy_type_one_fire_timer ||= 0

  # Create enemy2 bank
  args.state.enemy2s ||= [
    spawn_enemy_type_two(args),
    spawn_enemy_type_two(args),
    spawn_enemy_type_two(args)
  ]

  # Create enemy2 laser container
  args.state.enemy_type_two_lasers ||= []

  # Create enemy2 fire timer
  args.state.enemy_type_two_fire_timer ||= 0

  # Create add enemy timer
  args.state.spawn_time ||= 10
  args.state.add_enemy_timer ||= args.state.spawn_time
end

def input(args)
  if args.inputs.left

    args.state.player.x -= args.state.player.speed

  elsif args.inputs.right

    args.state.player.x += args.state.player.speed

  end

  if args.inputs.up

    args.state.player.y += args.state.player.speed

  elsif args.inputs.down

    args.state.player.y -= args.state.player.speed

  end

  args.state.player.x = args.grid.w - args.state.player.w if args.state.player.x + args.state.player.w > args.grid.w

  args.state.player.x = 0 if args.state.player.x.negative?

  args.state.player.y = args.grid.h - args.state.player.h if args.state.player.y + args.state.player.h > args.grid.h

  return unless args.state.player.y.negative?

  args.state.player.y = 0
end

def calc(args)
  scroll_background(args)
end

def render(args)
  if args.state.game_state == 1 || args.state.game_state == 3
    args.outputs.sprites << [args.state.bg1, args.state.bg2]
  elsif args.state.game_state == 2
    args.outputs.sprites << [args.state.bg1, args.state.bg2, args.state.player, args.state.enemy1s, args.state.enemy2s,
                             args.state.player_lasers, args.state.enemy_type_one_lasers, args.state.enemy_type_two_lasers]
  end

  if args.state.game_state == 1
    args.outputs.labels << [args.state.insturctions_label,
                            args.state.insturctions_label2]
  elsif args.state.game_state == 3
    args.outputs.labels << [args.state.play_again_label,
                            args.state.insturctions_label2]

  end
  args.outputs.labels << [args.state.score_label, args.state.last_score_label]
  args.outputs.sprites << [args.state.enemy2s]
end

def scroll_background(args)
  if args.state.game_state == 2
    args.state.bg1.y -= args.state.bg_speed
    args.state.bg2.y -= args.state.bg_speed
  end

  args.state.bg1.y = args.grid.h if args.state.bg1.y == -args.grid.h
  return unless args.state.bg2.y == -args.grid.h

  args.state.bg2.y = args.grid.h
end

def create_player_laser(args)
  # Create player lazer

  if (args.inputs.keyboard.key_held.z ||

       args.inputs.keyboard.key_held.j ||

       args.inputs.controller_one.key_held.a) && (args.state.player_fire_timer <= 0)
    args.audio[:fb] = { input: 'sounds/laser.wav', gain: 0.3 }
    args.state.player_lasers << {

      x: args.state.player.x + 16,

      y: args.state.player.y + args.state.player.h,

      w: 32,

      h: 16,

      path: 'sprites/player_bullet.png'

    }
    args.state.player_fire_timer = 0.2
  end
end

def move_player_laser(args)
  args.state.player_lasers.each do |laser|
    laser.y += args.state.player.speed + 2

    laser.dead = true if laser.y > args.grid.h - laser.h

    args.state.enemy1s.each do |enemy|
      next unless args.geometry.intersect_rect?(enemy, laser)

      args.audio[:hit] = { input: 'sounds/explosion.wav' }
      enemy.dead = true

      laser.dead = true

      args.state.score += 50

      args.state.enemy1s << spawn_enemy_type_one(args)
    end

    args.state.enemy2s.each do |enemy2|
      next unless args.geometry.intersect_rect?(enemy2, laser)

      args.audio[:hit] = { input: 'sounds/explosion.wav' }
      enemy2.dead = true

      laser.dead = true

      args.state.score += 100

      args.state.enemy2s << spawn_enemy_type_two(args)
    end
  end

  args.state.enemy1s.reject! { |e| e.dead }

  args.state.enemy2s.reject! { |e2| e2.dead }

  args.state.player_lasers.reject! { |l| l.dead }
end

def spawn_enemy_type_one(args)
  size = 64
  min_y = args.grid.h + size
  max_y = (args.grid.h + size) * 1.3

  {
    x: rand(args.grid.w - size),

    y: rand(max_y - min_y) + min_y,

    w: size,

    h: size,

    speed: 3,

    has_fired: false,

    path: 'sprites/enemy1.png'

  }
end

def move_enemy_type_one(args)
  size = 64
  args.state.enemy1s.each do |enemy|
    enemy.y -= enemy.speed

    next unless enemy.y < 0 - size

    enemy.dead = true
    args.state.enemy1s << spawn_enemy_type_one(args)
  end
  args.state.enemy1s.reject! { |e| e.dead }
end

def create_enemy_type_one_laser(args, x, y)
  return unless args.state.enemy1_fire_timer <= 0

  args.state.enemy_type_one_lasers << {

    x: x + 16,

    y: y,

    w: 32,

    h: 16,

    speed: 5,

    path: 'sprites/enemy_bullet.png'

  }
end

def move_enemy_type_one_laser(args)
  args.state.enemy1s.each do |ship|
    if ship.y < args.grid.h * 0.7 && ship.y > args.grid.h * 0.5 && (ship.has_fired == false)
      create_enemy_type_one_laser args, ship.x, ship.y
      ship.has_fired = true
    end
  end
  args.state.enemy_type_one_lasers.each do |laser|
    laser.y -= 7
  end
end

def handle_enemy_type_one_fire_timer(args)
  args.state.enemy_type_one_fire_timer -= 1 / args.state.fps
end

def spawn_enemy_type_two(args)
  size = 128
  min_y = args.grid.h + size
  max_y = (args.grid.h + size) * 1.6

  {
    x: rand(args.grid.w - size),

    y: rand(max_y - min_y) + min_y,

    w: size,

    h: size,

    speed: 4,

    has_fired: false,

    path: 'sprites/enemy2.png'

  }
end

def move_enemy_type_two(args)
  size = 128
  args.state.enemy2s.each do |enemy|
    enemy.y -= enemy.speed

    next unless enemy.y < 0 - size

    enemy.dead = true
    args.state.enemy2s << spawn_enemy_type_two(args)
  end
  args.state.enemy2s.reject! { |e| e.dead }
end

def create_enemy_type_two_laser(args, x, y)
  return unless args.state.enemy1_fire_timer <= 0

  args.state.enemy_type_two_lasers << {

    x: x + 32,

    y: y,

    w: 128,

    h: 32,

    speed: 9,

    path: 'sprites/enemy_bullet2.png'

  }
end

def move_enemy_type_two_laser(args)
  args.state.enemy2s.each do |ship|
    if ship.y < args.grid.h * 0.7 && ship.y > args.grid.h * 0.5 && (ship.has_fired == false)
      create_enemy_type_two_laser args, ship.x, ship.y
      ship.has_fired = true
    end
  end
  args.state.enemy_type_two_lasers.each do |laser|
    laser.y -= 9
  end
end

def handle_enemy_type_two_fire_timer(args)
  args.state.enemy_type_two_fire_timer -= 1 / args.state.fps
end

def handle_player_fire_timer(args)
  args.state.player_fire_timer -= 1 / args.state.fps
end

def check_for_game_over(args)
  return unless args.state.game_state == 2

  args.state.enemy_type_one_lasers.each do |laser|
    next unless args.geometry.intersect_rect?(args.state.player, laser)

    args.audio[:hit] = { input: 'sounds/explosion_player.wav' }
    args.state.game_state = 3
    args.state.player.x = args.grid.w / 2 - 32
    args.state.player.y = 50
    args.state.player_lasers = []
    args.state.enemy_type_one_lasers = []
    args.state.enemy1s = [
      spawn_enemy_type_one(args),
      spawn_enemy_type_one(args),
      spawn_enemy_type_one(args)
    ]
    args.state.enemy_type_two_lasers = []
    args.state.enemy2s = [
      spawn_enemy_type_two(args),
      spawn_enemy_type_two(args),
      spawn_enemy_type_two(args)
    ]
    args.state.last_score = args.state.score if args.state.score > args.state.last_score
    args.state.score = 0
  end

  args.state.enemy_type_two_lasers.each do |laser|
    next unless args.geometry.intersect_rect?(args.state.player, laser)

    args.audio[:hit] = { input: 'sounds/explosion_player.wav' }
    args.state.game_state = 3
    args.state.player.x = args.grid.w / 2 - 32
    args.state.player.y = 50
    args.state.player_lasers = []
    args.state.enemy_type_one_lasers = []
    args.state.enemy1s = [
      spawn_enemy_type_one(args),
      spawn_enemy_type_one(args),
      spawn_enemy_type_one(args)
    ]
    args.state.enemy_type_two_lasers = []
    args.state.enemy2s = [
      spawn_enemy_type_two(args),
      spawn_enemy_type_two(args),
      spawn_enemy_type_two(args)
    ]
    args.state.last_score = args.state.score if args.state.score > args.state.last_score
    args.state.score = 0
  end

  args.state.enemy1s.each do |ship|
    next unless args.geometry.intersect_rect?(args.state.player, ship)

    args.audio[:hit] = { input: 'sounds/explosion_player.wav' }
    args.state.game_state = 3
    args.state.player.x = args.grid.w / 2 - 32
    args.state.player.y = 50
    args.state.player_lasers ||= []
    args.state.enemy_type_one_lasers ||= []
    args.state.enemy1s = [
      spawn_enemy_type_one(args),
      spawn_enemy_type_one(args),
      spawn_enemy_type_one(args)
    ]
    args.state.enemy_type_two_lasers = []
    args.state.enemy2s = [
      spawn_enemy_type_two(args),
      spawn_enemy_type_two(args),
      spawn_enemy_type_two(args)
    ]
    args.state.last_score = args.state.score if args.state.score > args.state.last_score
    args.state.score = 0
  end

  args.state.enemy2s.each do |ship|
    next unless args.geometry.intersect_rect?(args.state.player, ship)

    args.audio[:hit] = { input: 'sounds/explosion_player.wav' }
    args.state.game_state = 3
    args.state.player.x = args.grid.w / 2 - 32
    args.state.player.y = 50
    args.state.player_lasers ||= []
    args.state.enemy_type_one_lasers ||= []
    args.state.enemy1s = [
      spawn_enemy_type_one(args),
      spawn_enemy_type_one(args),
      spawn_enemy_type_one(args)
    ]
    args.state.enemy_type_two_lasers = []
    args.state.enemy2s = [
      spawn_enemy_type_two(args),
      spawn_enemy_type_two(args),
      spawn_enemy_type_two(args)
    ]
    args.state.last_score = args.state.score if args.state.score > args.state.last_score
    args.state.score = 0
  end
end

def add_enemy(args)
  args.state.add_enemy_timer -= 1 / args.state.fps
  return unless args.state.add_enemy_timer < 0

  d6 = rand(6)
  if d6 <= 4
    args.state.enemy1s << spawn_enemy_type_one(args)
  else
    args.state.enemy2s << spawn_enemy_type_two(args)
  end

  args.state.add_enemy_timer = args.state.spawn_time
end

def tick(args)
  defaults args

  if args.state.game_state == 1 && args.inputs.keyboard.key_held.z || args.inputs.keyboard.key_held.j || args.inputs.controller_one.key_held.a
    args.state.game_state = 2
  end

  if args.state.game_state == 3 && args.inputs.keyboard.key_held.z || args.inputs.keyboard.key_held.j || args.inputs.controller_one.key_held.a
    args.state.game_state = 2
  end

  if args.state.game_state == 2
    check_for_game_over args
    input args

    create_player_laser args
    move_player_laser args

    handle_player_fire_timer args
    handle_enemy_type_one_fire_timer args
    handle_enemy_type_two_fire_timer args

    move_enemy_type_one args
    move_enemy_type_one_laser args
    move_enemy_type_two args
    move_enemy_type_two_laser args

    add_enemy args
  end


  calc args
  render args
end

$gtk.reset
