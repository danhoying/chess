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

  def move_possible?(piece, column, row)
    if piece.color == "white"
      if column - piece.column == 1 && piece.row == row
        true
      elsif piece.column == 1 && column - piece.column == 2 && piece.row == row
        true
      elsif column - piece.column == 1 && piece.row - row == 1 || row - piece.row == 1
        true
      else
        false
      end
    elsif piece.color == "black"
      if piece.column - column == 1 && piece.row == row
        true
      elsif piece.column == 6 && piece.column - column == 2 && piece.row == row
        true
      elsif piece.column - column == 1 && piece.row - row == 1 || row - piece.row == 1
        true
      else
        false
      end
    end
  end

end

class Knight < Piece

  def initialize(color, symbol, column, row)
    super
  end

  def move_possible?(piece, column, row)
    c = piece.column
    r = piece.row
    possible_moves = [[c + 2, r + 1], [c + 2, r - 1], [c - 2, r + 1], [c - 2, r - 1],
                      [c + 1, r + 2], [c - 1, r + 2], [c + 1, r - 2], [c - 1, r - 2]]
    possible_moves.each do |move|
      if move[0].eql?(column) && move[1].eql?(row)
        return true
      end
    end
    return false
  end
end

class Bishop < Piece

  def initialize(color, symbol, column, row)
    super
  end 

  def move_possible?(piece, column, row)
    count = 1
    c = piece.column
    r = piece.row
    possible_moves = []
    until count == 8
      possible_moves << [c + count, r + count]
      possible_moves << [c - count, r - count]
      possible_moves << [c + count, r - count]
      possible_moves << [c - count, r + count]
      count += 1
    end
    possible_moves.each do |move|
      if move[0].eql?(column) && move[1].eql?(row)
        return true
      end
    end
    return false
  end
end

class Rook < Piece

  def initialize(color, symbol, column, row)
    super
  end  

  def move_possible?(piece, column, row)
    count = 1
    c = piece.column
    r = piece.row
    possible_moves = []
    until count == 8
      possible_moves << [c + count, r]
      possible_moves << [c - count, r]
      possible_moves << [c, r + count]
      possible_moves << [c, r - count]
      count += 1
    end
    possible_moves.each do |move|
      if move[0].eql?(column) && move[1].eql?(row)
        return true
      end
    end
    return false
  end
end

class Queen < Piece

  def initialize(color, symbol, column, row)
    super
  end 

  def move_possible?(piece, column, row)
    count = 1
    c = piece.column
    r = piece.row
    possible_moves = []
    until count == 8
      possible_moves << [c + count, r + count]
      possible_moves << [c - count, r - count]
      possible_moves << [c + count, r - count]
      possible_moves << [c - count, r + count]
      possible_moves << [c + count, r]
      possible_moves << [c - count, r]
      possible_moves << [c, r + count]
      possible_moves << [c, r - count]
      count += 1
    end
    possible_moves.each do |move|
      if move[0].eql?(column) && move[1].eql?(row)
        return true
      end
    end
    return false
  end
end

class King < Piece

  def initialize(color, symbol, column, row)
    super
  end

  def move_possible?(piece, column, row)
    c = piece.column
    r = piece.row
    possible_moves = []
    possible_moves << [c + 1, r + 1]
    possible_moves << [c - 1, r - 1]
    possible_moves << [c + 1, r - 1]
    possible_moves << [c - 1, r + 1]
    possible_moves << [c + 1, r]
    possible_moves << [c - 1, r]
    possible_moves << [c, r + 1]
    possible_moves << [c, r - 1]
    possible_moves.each do |move|
      if move[0].eql?(column) && move[1].eql?(row)
        return true
      end
    end
    return false
  end
end
