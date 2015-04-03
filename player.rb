require 'gosu'

class Player

  WIDTH  = 54
  HEIGHT = 60

  attr_accessor :images
  attr_accessor :jump_speed
  attr_accessor :position
  attr_accessor :rotation
  attr_accessor :size

  def initialize(window)
    self.images = [
      Gosu::Image.new(window, 'images/tails_1.png', false),
      Gosu::Image.new(window, 'images/tails_2.png', false),
      Gosu::Image.new(window, 'images/tails_3.png', false),
      Gosu::Image.new(window, 'images/tails_4.png', false),
      Gosu::Image.new(window, 'images/tails_5.png', false),
      Gosu::Image.new(window, 'images/tails_6.png', false)
    ]
    self.size = GameVector.new(WIDTH, HEIGHT)
    self.jump_speed = GameVector.new(0, 0)
    self.position = GameVector.new(50, 270)
    self.rotation = 0
  end

  def rectangle
    Rectangle.new(pos: position, size: size)
  end

  def self.width;  WIDTH;  end
  def self.height; HEIGHT; end
end