class Rectangle
  attr_accessor :pos
  attr_accessor :size

  def initialize(args)
    self.pos = args[:pos]
    self.size = args[:size]
  end

  def min_x
    pos.x
  end

  def min_y
    pos.y
  end

  def max_x
    pos.x + size.x
  end

  def max_y
    pos.y + size.y
  end

  def intersect?(rectangle)
    !(max_x < rectangle.min_x ||
      min_x > rectangle.max_x ||
      min_y > rectangle.max_y ||
      max_y < rectangle.min_y)
  end

end