require_relative 'piece'

class Board

  def initialize
    @white_pieces = []
    @white_pieces << Pawn.new("white", ("\u265F"), 1, 0)
    @white_pieces << Pawn.new("white", ("\u265F"), 1, 1)
    @white_pieces << Pawn.new("white", ("\u265F"), 1, 2)
    @white_pieces << Pawn.new("white", ("\u265F"), 1, 3)
    @white_pieces << Pawn.new("white", ("\u265F"), 1, 4)
    @white_pieces << Pawn.new("white", ("\u265F"), 1, 5)
    @white_pieces << Pawn.new("white", ("\u265F"), 1, 6)
    @white_pieces << Pawn.new("white", ("\u265F"), 1, 7)

    @white_pieces << Rook.new("white", ("\u265C"), 0, 0)
    @white_pieces << Knight.new("white", ("\u265E"), 0, 1)
    @white_pieces << Bishop.new("white", ("\u265D"), 0, 2)
    @white_pieces << Queen.new("white", ("\u265B"), 0, 3) 
    @white_pieces << @white_king = King.new("white", ("\u265A"), 0, 4)
    @white_pieces << Bishop.new("white", ("\u265D"), 0, 5)
    @white_pieces << Knight.new("white", ("\u265E"), 0, 6)
    @white_pieces << Rook.new("white", ("\u265C"), 0, 7)

    @black_pieces = []
    @black_pieces << Pawn.new("black", ("\u2659"), 6, 0)
    @black_pieces << Pawn.new("black", ("\u2659"), 6, 1)
    @black_pieces << Pawn.new("black", ("\u2659"), 6, 2)
    @black_pieces << Pawn.new("black", ("\u2659"), 6, 3)
    @black_pieces << Pawn.new("black", ("\u2659"), 6, 4)
    @black_pieces << Pawn.new("black", ("\u2659"), 6, 5)
    @black_pieces << Pawn.new("black", ("\u2659"), 6, 6)
    @black_pieces << Pawn.new("black", ("\u2659"), 6, 7)

    @black_pieces << Rook.new("black", ("\u2656"), 7, 0)
    @black_pieces << Knight.new("black", ("\u2658"), 7, 1)
    @black_pieces << Bishop.new("black", ("\u2657"), 7, 2)
    @black_pieces << Queen.new("black", ("\u2655"), 7, 3)
    @black_pieces << @black_king = King.new("black", ("\u2654"), 7, 4)
    @black_pieces << Bishop.new("black", ("\u2657"), 7, 5)
    @black_pieces << Knight.new("black", ("\u2658"), 7, 6)
    @black_pieces << Rook.new("black", ("\u2656"), 7, 7)

    @board = create_board
    @empty_square = "___"
  end

  def create_board
    board = []
    8.times do 
      board.push(["___", "___", "___", "___", "___", "___", "___", "___"])
    end
    @white_pieces[0..7].each_with_index do |piece, index|
      board[piece.column][piece.row] = piece
    end
    @white_pieces[8..15].each_with_index do |piece, index|
      board[piece.column][piece.row] = piece
    end
    @black_pieces[0..7].each_with_index do |piece, index|
      board[piece.column][piece.row] = piece
    end
    @black_pieces[8..15].each_with_index do |piece, index|
      board[piece.column][piece.row] = piece
    end
    board
  end

  def display_board
    count = 9 # For labeling numbers on side of board
    puts ""
    puts "  _a_ _b_ _c_ _d_ _e_ _f_ _g_ _h_"
    @board.reverse.each do |row|
      print "#{count - 1}|"
      row.each do |item|
        if !item.instance_of? String
          print "_#{item.symbol}_|"
        else
          print "___|"
        end
      end
      print "#{count - 1}"
      count -= 1
      puts " "
    end
     print "   a   b   c   d   e   f   g   h" 
     puts ""
     @board
  end

  # Checks if the current player incorrectly chose an opponent's piece.
  def check_color?(piece, player)
    piece == player.downcase ? true : false
  end

  # Updates current piece's location parameters and moves piece to new location.
  def move(piece, column, row) 
    piece.column = column
    piece.row = row
    @board[piece.column][piece.row] = piece
  end

  # Changes a space to blank after a piece is moved from it.
  def empty_space(column, row)
    @board[column][row] = @empty_square
  end

  # Checks if space is an empty square.
  def space_open?(column, row)
    @board[column][row] == @empty_square ? true : false
  end

  # Returns appropriate space on board.
  def check(column, row)
    if @board[column][row] == nil
      return nil
    elsif @board[column][row] == "___"
      return "___"
    else
      return @board[column][row]
    end
  end
end
