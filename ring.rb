require_relative 'game_vector'
require_relative 'rectangle'

class Ring

  WIDTH = 32
  HEIGHT = 32
  attr_accessor :pos
  attr_accessor :collected

  def initialize(pos_x, pos_y)
    self.pos = GameVector.new(pos_x, pos_y)
    self.collected = false
  end

  def collected?; collected; end

  def rectangle
    Rectangle.new(pos: pos.dup, size: Ring.size_vector)
  end

  def to_s
    "[#{pos.x}, #{pos.y}]"
  end

  def self.width;  WIDTH;  end
  def self.height; HEIGHT; end

  def self.size_vector
    GameVector.new(width, height)
  end
end