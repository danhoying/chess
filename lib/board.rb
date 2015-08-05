require_relative 'piece'

class Board

  def initialize
    @white_pieces = []
    @white_pieces << @w_pawn1 = Pawn.new("white", ("\u265F"), 1, 0)
    @white_pieces << @w_pawn2 = Pawn.new("white", ("\u265F"), 1, 1)
    @white_pieces << @w_pawn3 = Pawn.new("white", ("\u265F"), 1, 2)
    @white_pieces << @w_pawn4 = Pawn.new("white", ("\u265F"), 1, 3)
    @white_pieces << @w_pawn5 = Pawn.new("white", ("\u265F"), 1, 4)
    @white_pieces << @w_pawn6 = Pawn.new("white", ("\u265F"), 1, 5)
    @white_pieces << @w_pawn7 = Pawn.new("white", ("\u265F"), 1, 6)
    @white_pieces << @w_pawn8 = Pawn.new("white", ("\u265F"), 1, 7)

    @white_pieces << @w_rook1 = Rook.new("white", ("\u265C"), 0, 0)
    @white_pieces << @w_knight1 = Knight.new("white", ("\u265E"), 0, 1)
    @white_pieces << @w_bishop1 = Bishop.new("white", ("\u265D"), 0, 2)
    @white_pieces << @w_queen = Queen.new("white", ("\u265B"), 0, 3) 
    @white_pieces << @w_king = King.new("white", ("\u265A"), 0, 4)
    @white_pieces << @w_bishop2 = Bishop.new("white", ("\u265D"), 0, 5)
    @white_pieces << @w_knight2 = Knight.new("white", ("\u265E"), 0, 6)
    @white_pieces << @w_rook2 = Rook.new("white", ("\u265C"), 0, 7)

    @black_pieces = []
    @black_pieces << @b_pawn1 = Pawn.new("black", ("\u2659"), 6, 0)
    @black_pieces << @b_pawn2 = Pawn.new("black", ("\u2659"), 6, 1)
    @black_pieces << @b_pawn3 = Pawn.new("black", ("\u2659"), 6, 2)
    @black_pieces << @b_pawn4 = Pawn.new("black", ("\u2659"), 6, 3)
    @black_pieces << @b_pawn5 = Pawn.new("black", ("\u2659"), 6, 4)
    @black_pieces << @b_pawn6 = Pawn.new("black", ("\u2659"), 6, 5)
    @black_pieces << @b_pawn7 = Pawn.new("black", ("\u2659"), 6, 6)
    @black_pieces << @b_pawn8 = Pawn.new("black", ("\u2659"), 6, 7)

    @black_pieces << @b_rook1 = Rook.new("black", ("\u2656"), 7, 0)
    @black_pieces << @b_knight1 = Knight.new("black", ("\u265E"), 7, 1)
    @black_pieces << @b_bishop1 = Bishop.new("black", ("\u2657"), 7, 2)
    @black_pieces << @b_queen = Queen.new("black", ("\u2655"), 7, 3)
    @black_pieces << @b_king = King.new("black", ("\u2654"), 7, 4)
    @black_pieces << @b_bishop2 = Bishop.new("black", ("\u2657"), 7, 5)
    @black_pieces << @b_knight2 = Knight.new("black", ("\u265E"), 7, 6)
    @black_pieces << @b_rook2 = Rook.new("black", ("\u2656"), 7, 7)

    @board = create_board
    @empty_square = "_"
  end

  def create_board
    board = []
    8.times do 
      board.push(["___", "___", "___", "___", "___", "___", "___", "___"])
    end
    @white_pieces[0..7].each_with_index do |piece, index|
      board[1][index] = (["_#{piece.symbol}_"])
    end
    @white_pieces[8..15].each_with_index do |piece, index|
      board[0][index] = (["_#{piece.symbol}_"])
    end
    @black_pieces[0..7].each_with_index do |piece, index|
      board[6][index] = (["_#{piece.symbol}_"])
    end
    @black_pieces[8..15].each_with_index do |piece, index|
      board[7][index] = (["_#{piece.symbol}_"])
    end
    board
  end

  def display_board
    count = 9
    puts ""
    puts "  _a_ _b_ _c_ _d_ _e_ _f_ _g_ _h_"
    @board.reverse.each do |row|
      print  "#{count - 1}|#{row.join('|')}|#{count - 1}"
      count -= 1
      puts " "
    end
     print "   a   b   c   d   e   f   g   h" 
     puts ""
     puts ""
     @board
  end

end


