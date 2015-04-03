class GameVector

  attr_accessor :x
  attr_accessor :y

  def initialize(x, y)
    self.x = x
    self.y = y
    self
  end

  def set!(vector)
    self.x = vector.x
    self.y = vector.y
  end

  def +(vector)
    GameVector.new(x + vector.x, y + vector.y)
  end

  def -(vector)
    GameVector.new(x - vector.x, y - vector.y)
  end

  def *(scalar)
    GameVector.new(x * scalar, y * scalar)
  end

  def -@
    GameVector.new(-x, -y)
  end

  def ==(vector)
    x == vector.x && y == vector.y
  end

  def coerce(left)
    [self, left]
  end
end