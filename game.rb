require 'gosu'
require_relative 'game_state'
require_relative 'game_vector'
require_relative 'obstacle'
require_relative 'player'
require_relative 'rectangle'
require_relative 'ring'

GRAVITY = GameVector.new(0, 900) #pixels/s^2
JUMP_VEL = GameVector.new(0, -300)
OBSTACLE_SPEED = 250 #pixels/s
OBSTACLE_SPAWN_INTERVAL = 1.2 #seconds
OBSTACLE_GAP = 200
DEATH_VELOCITY = GameVector.new(-300, -100) #pixels/s
DEATH_ROTATIONAL_VEL = 360 #degrees/s
RESTART_INTERVAL = 3 #seconds

class GameWindow < Gosu::Window

  def initialize(*args)
    super
    @font_title = Gosu::Font.new(self, "fonts/Sonic Title Font.ttf", 50)
    @font = Gosu::Font.new(self, "fonts/Gaslight Regular.ttf", 30)
    @player = Player.new(self)
    @images = {
      background: Gosu::Image.new(self, 'images/background.png', false),
      foreground: Gosu::Image.new(self, 'images/foreground.png', true),
      ring: [
        Gosu::Image.new(self, 'images/ring_1.png', false),
        Gosu::Image.new(self, 'images/ring_2.png', false),
        Gosu::Image.new(self, 'images/ring_3.png', false),
        Gosu::Image.new(self, 'images/ring_4.png', false),
        Gosu::Image.new(self, 'images/ring_5.png', false),
        Gosu::Image.new(self, 'images/ring_6.png', false),
        Gosu::Image.new(self, 'images/ring_7.png', false),
        Gosu::Image.new(self, 'images/ring_8.png', false)
      ],
      obstacle:   Gosu::Image.new(self, 'images/obstacle.png', false)
    }
    @rotation_count = 0
    @ring_sound = Gosu::Sample.new(self, "samples/ring.wav")
    @death_sound = Gosu::Sample.new(self, "samples/death.wav")
    @jump_sound = Gosu::Sample.new(self, "samples/jump.wav")
    @music = Gosu::Sample.new(self, "samples/music.mp3")
    start_game
    @music.play(1, 1, true)
  end

  def button_down(button)
    case button
    when Gosu::KbEscape
      close
    when Gosu::KbSpace
      @player.jump_speed.set!(JUMP_VEL) if @state.alive
      @jump_sound.play
      @state.started = true
    end
  end

  def spawn_obstacle_and_ring
    obstacle = Obstacle.new(pos: GameVector.new(width, rand(50..320)), crossed: false)
    @state.obstacles << obstacle
    @state.rings << Ring.new(obstacle.pos.x + Obstacle.width/2 - Ring.width/2, obstacle.pos.y + OBSTACLE_GAP/2 - Ring.height/2)
  end

  def update
    dt = (update_interval  / 1000.0)

    @rotation_count += 1

    @state.scroll_x += dt * OBSTACLE_SPEED * 0.5
    @state.scroll_x = 0 if @state.scroll_x > @images[:foreground].width

    return unless @state.started

    @player.jump_speed += dt * GRAVITY
    @player.position += dt * @player.jump_speed

    @images[:ring].rotate! if @rotation_count % 3 == 0
    @player.images.rotate! if @rotation_count % 6 == 0

    @state.obstacle_countdown -= dt
    if @state.obstacle_countdown <= 0
      spawn_obstacle_and_ring
      @state.obstacle_countdown += OBSTACLE_SPAWN_INTERVAL
    end

    @state.obstacles.each do |obstacle|
      obstacle.pos.x -= dt * OBSTACLE_SPEED
      if obstacle.pos.x < @player.position.x && !obstacle.crossed && @state.alive
        obstacle.crossed = true
      end
    end

    @state.rings.each do |ring|
      ring.pos.x -= dt * OBSTACLE_SPEED
      if player_is_collecting?(ring) && @state.alive
        @state.score += 1
        @ring_sound.play
        ring.collected = true
      end
    end

    @state.obstacles.reject! { |obstacle| obstacle.pos.x < -Obstacle.width }
    @state.rings.reject!(&:collected)

    if @state.alive && player_is_colliding?
      @state.alive = false
      @death_sound.play
      @player.jump_speed.set!(DEATH_VELOCITY)
    end

    unless @state.alive
      @player.rotation += dt * DEATH_ROTATIONAL_VEL
      @state.restart_countdown -= dt
      start_game if @state.restart_countdown <= 0
    end
  end

  def draw
    @images[:background].draw(0, 0, 0);
    @images[:foreground].draw(-@state.scroll_x, 0, 0);
    @images[:foreground].draw(-@state.scroll_x + @images[:foreground].width, 0, 0);

    @state.obstacles.each do |obstacle|
      img_y = Obstacle.height
      # top
      @images[:obstacle].draw(obstacle.pos.x, obstacle.pos.y - img_y, 0)
      # bottom
      scale(1, -1) do
        @images[:obstacle].draw(obstacle.pos.x, -img_y - obstacle.pos.y - OBSTACLE_GAP, 0)
      end
    end

    @state.rings.each do |ring|
      @images[:ring].first.draw(ring.pos.x, ring.pos.y, 0) unless ring.collected?
    end

    @player.images.first.draw_rot(@player.position.x, @player.position.y, 0, @player.rotation, 0, 0)
    @font.draw("Rings: #{@state.score}", 20, 20, 0)
    @font_title.draw_rel("flappy tails", width/2, height/2, 0, 0.5, 0.5, 1, 1, Gosu::Color::WHITE) unless @state.started
    @font.draw_rel("Press Space to Start", width/2, height*2/3, 0, 0.5, 0.5, 2, 2, Gosu::Color::YELLOW) unless @state.started
    @font.draw_rel("Score #{@state.score}", width/2, height/2, 0, 0.5, 0.5, 3, 3, Gosu::Color::YELLOW) unless @state.alive
  end

  def obstacle_rects
    img_y = Obstacle.height
    img_x = Obstacle.width
    obstacle_size = GameVector.new(img_x, img_y)

    @state.obstacles.flat_map do |obstacle|
      top = obstacle.rectangle(true)
      bottom = obstacle.rectangle(false)
      [top, bottom]
    end
  end

  def debug_draw
    color = player_is_colliding? ? Gosu::Color::RED : Gosu::Color::GREEN
    draw_debug_rect(@player.rectangle, color)
    obstacle_rects.each do |rect|
      draw_debug_rect(rect)
    end
    @state.rings.each do |ring|
      draw_debug_rect(ring.rectangle)
    end
  end

  def draw_debug_rect(rect, color = Gosu::Color::GREEN)
    x = rect.pos.x
    y = rect.pos.y
    w = rect.size.x
    h = rect.size.y

    points = [
      GameVector.new(x, y),
      GameVector.new(x + w, y),
      GameVector.new(x + w, y + h),
      GameVector.new(x, y + h)
    ]
    points.each_with_index do |p1, index|
      p2 = points[(index + 1) % points.size]
      draw_line(p1.x, p1.y, color, p2.x, p2.y, color)
    end
  end

  def player_is_colliding?
    return true if obstacle_rects.find do |obstacle_rect|
      @player.rectangle.intersect?(obstacle_rect)
    end
    !@player.rectangle.intersect?(Rectangle.new(pos: GameVector.new(0, 0), size: GameVector.new(width, height)))
  end

  def player_is_collecting?(ring)
    @player.rectangle.intersect?(Rectangle.new(pos: ring.pos.dup, size: Ring.size_vector))
  end

  def start_game
    old_state = @state
    @state = GameState.new(
      {
        obstacle_countdown: OBSTACLE_SPAWN_INTERVAL,
        restart_countdown: RESTART_INTERVAL,
        obstacles: [],
        rings: []
      })
    @player = Player.new(self)
  end
end

window = GameWindow.new(800, 600, false);
window.show