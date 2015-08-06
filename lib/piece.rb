class Piece

  attr_accessor :color, :symbol, :column, :row

  def initialize(color, symbol, column, row)
    @color = color
    @symbol = symbol
    @column = column
    @row = row
  end
end

class Pawn < Piece

  def initialize(color, symbol, column, row)
    super
  end

  def move_possible?(column, row)
    new_column = column + 1
    new_row = row
    if new_column = column + 1 && new_row == row
      true
    else
      false
    end
  end

end

class Knight < Piece

  def initialize(color, symbol, column, row)
    super
  end
end

class Bishop < Piece

  def initialize(color, symbol, column, row)
    super
  end 
end

class Rook < Piece

  def initialize(color, symbol, column, row)
    super
  end  
end

class Queen < Piece

  def initialize(color, symbol, column, row)
    super
  end 
end

class King < Piece

  def initialize(color, symbol, column, row)
    super
  end
end
