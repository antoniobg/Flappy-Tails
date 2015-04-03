require_relative 'game_vector'

class Obstacle

  attr_accessor :pos
  attr_accessor :crossed

  DEFAULT_VALUES = { pos: GameVector.new(0, 0), crossed: false }
  WIDTH = 106
  HEIGHT = 600
  GAP = 200

  def initialize(args)
    args = DEFAULT_VALUES.merge(args)
    self.pos = args[:pos]
    self.crossed = args[:crossed]
  end

  def rectangle(top)
    if top
      Rectangle.new(pos: GameVector.new(pos.x, pos.y - Obstacle.height), size: Obstacle.size_vector)
    else
      Rectangle.new(pos: GameVector.new(pos.x, pos.y + GAP), size: Obstacle.size_vector)
    end
  end

  def self.width;  WIDTH;  end

  def self.height; HEIGHT; end

  def self.gap;    GAP;    end

  def self.size_vector
    GameVector.new(width, height)
  end

end