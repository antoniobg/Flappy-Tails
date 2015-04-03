require_relative 'game_vector'
require_relative 'player'

class GameState
  attr_accessor :started
  attr_accessor :score
  attr_accessor :alive
  attr_accessor :scroll_x
  attr_accessor :player_pos
  attr_accessor :player_vel
  attr_accessor :player_rotation
  attr_accessor :obstacles
  attr_accessor :obstacle_countdown
  attr_accessor :restart_countdown
  attr_accessor :rings

  DEFAULT_VALUES = {
    started: false,
    score: 0,
    alive: true,
    scroll_x: 0,
    obstacles: [], # array of Obstacle
    rings: [], # array of rings
    obstacle_countdown: 0,
    restart_countdown: 0
  }
  def initialize(args)
    args = DEFAULT_VALUES.merge(args)
    args.each do |attr_name, attr_value|
      self.send("#{attr_name}=", attr_value)
    end
  end
end