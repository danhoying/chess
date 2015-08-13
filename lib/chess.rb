require 'yaml'

require_relative 'board'
require_relative 'piece'

class Chess

  attr_accessor :player1, :player2, :current_player, :current_piece, :board

  def initialize
    @player1 = Player.new("White")
    @player2 = Player.new("Black")
    @current_player = player1
    @current_piece = Piece.new("white", nil, nil, nil)
    @board = Board.new
  end

  def start_game
    Dir.mkdir("save") unless Dir.exists? "save"
    display_intro
    game_choice
    display_instructions
    game_turn
  end

  def game_turn
    until false
      display_save_message
      @board.display_board
      select_piece
      move_piece
      display_past_move
      switch_players
    end
  end

  def game_choice
    print "Would you like to load a saved game? (Please enter 'y' if you would). "
    choice = gets.chomp.downcase
    if choice.include? "y"
      load_game
    end
  end

  def save_game
    Dir.chdir("save")
    File.open("save.txt", 'w') { |file| file.write(YAML::dump(self))}
    puts "Game Saved!"
    Dir.chdir("..")
    exit
  end

  def load_game
    Dir.chdir("save")
    if File.exist?("save.txt")
      game = YAML::load(File.read("save.txt"))
      puts "Game Loaded!"
      puts ""
      Dir.chdir("..")
      game.game_turn
    else
      puts "You have no saved games."
      puts ""
      Dir.chdir("..")
    end
  end

  def play_again?
    print "Do you want to play again? "
    entry = gets.chomp.downcase
    if entry.include? "y"
      return true
    else
      return false
    end
  end 

  def display_intro
    puts ""
    puts "~+~+~+~+~+~+~+~+~+~+~+~  WELCOME TO CHESS!  ~+~+~+~+~+~+~+~+~+~+~+~+~"
    puts ""
  end

  def display_instructions
    puts ""
    puts "Player 1 will be #{player1.color} and Player 2 will be #{player2.color}."
    puts ""
    puts "To enter your move, please enter the letter/number combo (e.g. g1)"
    puts "of the piece you would like to move. Next, enter the letter/number"
    puts "combo of the location you would like to move to."
    puts ""
  end

  def display_past_move
    puts ""
    puts "#{@current_player.color} previous move: #{@initial_move} => #{@final_move}"
  end

  def display_save_message
    puts "Type 'save' to save and quit your game."
  end

  def switch_players
    @current_player == @player1 ? @current_player = @player2 : @current_player = @player1
  end

  # Asks current player to select a piece to move.
  def select_piece
    move = "99"
    column = 99
    row = 99
    until ('a'..'h').include?(move[0]) && ('1'..'8').include?(move[1]) && 
        move.length == 2 && !@board.space_open?(column, row)
      puts "" 
      print "#{@current_player.color}, please select a piece to move: "
      move = gets.chomp
      if move == 'save'
        save_game
      end
      row = translate_row(move, row)
      column = translate_column(move, column)
      @initial_move = move
      @initial_column = column
      @initial_row = row
      if !('a'..'h').include?(move[0]) || !('1'..'8').include?(move[1]) || move.length != 2
        puts "That is not a valid entry.  Please enter a letter/number combo (e.g. d2)."
      elsif @board.space_open?(column, row)
        puts "You chose an empty space.  Please choose a space that contains a piece."
      end
    end
    @current_piece = @board.check(column, row)
    ensure_correct_color(@current_piece)
    check_for_move_possibility(@current_piece, column, row)
  end

  def check_for_move_possibility(piece, column, row)
    pawn_impossible(piece, column, row)
    bishop_impossible(piece, column, row)
    rook_impossible(piece, column, row)
    knight_impossible(piece, column, row)
    queen_impossible(piece, column, row)
    king_impossible(piece, column, row)
  end

  # Special method that determines if two pieces are facing one another and
  # cannot move. Allows the player to choose a new piece.
  def pawn_impossible(piece, column, row)
    if piece.is_a?(Pawn) && piece.color == "white" && 
      @board.check(column + 1, row + 1) != nil &&
      @board.check(column + 1, row - 1) != nil &&
      !@board.space_open?(column + 1, row) && @board.space_open?(column + 1, row + 1) && 
        @board.space_open?(column + 1, row - 1)
      puts "A move is not possible here. Please select another piece."
      select_piece
    elsif piece.is_a?(Pawn) && piece.color == "black" && 
      @board.check(column -1, row + 1) != nil &&
      @board.check(column -1, row - 1) != nil &&
      !@board.space_open?(column - 1, row) && @board.space_open?(column - 1, row + 1) && 
        @board.space_open?(column - 1, row - 1)
      puts "A move is not possible here. Please select another piece."
      select_piece
    end
  end

  def bishop_impossible(piece, column, row)
    if piece.is_a?(Bishop)
      nearby = []
      items = 0
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
        possible_moves.each do |move|
          if count == 2 && move.all? { |value| value >= 0 } && move.all? { |value| value <= 7 }
            nearby << move
          end
        end
        nearby.each do |i|
          if @board.check(i[0], i[1]) != "___" && @board.check(i[0], i[1]).color == piece.color
            items += 1
          else
            items = 0
          end
        end
        if items == nearby.count
          puts "A move is not possible here. Please select another piece."
          select_piece
        end
      end   
    end
  end

  def rook_impossible(piece, column, row)
    if piece.is_a?(Rook) 
      nearby = []
      items = 0
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
        possible_moves.each do |move|
          if count == 2 && move.all? { |value| value >= 0 } && move.all? { |value| value <= 7 }
            nearby << move
          end
        end
        nearby.each do |i|
          if @board.check(i[0], i[1]) != "___" && @board.check(i[0], i[1]).color == piece.color
            items += 1
          else 
            items = 0
          end
        end
        if items == nearby.count
          puts "A move is not possible here. Please select another piece."
          select_piece
        end  
      end
    end
  end

  def knight_impossible(piece, column, row)
    if piece.is_a?(Knight)
      items = 0
      c = piece.column
      r = piece.row
      possible_moves = [[c + 2, r + 1], [c + 2, r - 1], [c - 2, r + 1], [c - 2, r - 1],
                      [c + 1, r + 2], [c - 1, r + 2], [c + 1, r - 2], [c - 1, r - 2]]
      possible_moves.each do |move|
        if @board.check(move[0], move[1]) != "___" && @board.check(move[0], move[1]).color == piece.color
          items += 1
        else 
          items = 0
        end
      end
      if items == possible_moves.count
        puts "A move is not possible here. Please select another piece."
        select_piece 
      end
    end
  end

  def queen_impossible(piece, column, row)
    if piece.is_a?(Queen) 
      nearby = []
      items = 0
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
        possible_moves.each do |move|
          if count == 2 && move.all? { |value| value >= 0 } && move.all? { |value| value <= 7 }
            nearby << move
          end
        end
        nearby.each do |i|
          if @board.check(i[0], i[1]) != "___" && @board.check(i[0], i[1]).color == piece.color
            items += 1
          else 
            items = 0
          end
        end
        if items == nearby.count
          puts "A move is not possible here. Please select another piece."
          select_piece
        end  
      end
    end
  end

  def king_impossible(piece, column, row)
    if piece.is_a?(King) 
      nearby = []
      items = 0
      count = 1
      c = piece.column
      r = piece.row
      possible_moves = []
      possible_moves << [c + count, r + count]
      possible_moves << [c - count, r - count]
      possible_moves << [c + count, r - count]
      possible_moves << [c - count, r + count]
      possible_moves << [c + count, r]
      possible_moves << [c - count, r]
      possible_moves << [c, r + count]
      possible_moves << [c, r - count]
      possible_moves.each do |move|
        if move.all? { |value| value >= 0 } && move.all? { |value| value <= 7 }
          nearby << move
        end
      end
      nearby.each do |i|
        if @board.check(i[0], i[1]) != "___" && @board.check(i[0], i[1]).color == piece.color
          items += 1
        else 
          items = 0
        end
      end
      if items == nearby.count
        puts "A move is not possible here. Please select another piece."
        select_piece 
      end
    end
  end

  # Loops through #select_piece until a piece matching the current player's color is chosen.
  def ensure_correct_color(piece)
    until @board.check_color?(@current_piece.color, @current_player.color)
      puts "You selected your opponent's piece. Try again."
      select_piece
    end
    @current_piece
  end

  # Asks current player to choose the selected piece's destination location.
  def move_piece
    move = "99"
    column = 99
    row = 99
    until ('a'..'h').include?(move[0]) && ('1'..'8').include?(move[1]) && 
          move.length == 2
      puts ""
      print "#{@current_player.color}, please select a destination: "
      move = gets.chomp
      @final_move = move
      row = translate_row(move, row)
      column = translate_column(move, column)
      if !('a'..'h').include?(move[0]) || !('1'..'8').include?(move[1]) || move.length != 2
        puts "That is not a valid entry.  Please enter a letter/number combo (e.g. d3)."
      end
    end
    if @board.space_open?(column, row)
      ensure_correct_move(@current_piece, column, row)
    elsif !@board.space_open?(column, row)
      forbid_taking_own_color(@current_piece, column, row)
    end
  end

  # Doesn't allow player to move to square occupied by own piece.
  def forbid_taking_own_color(piece, column, row)
    check_piece = @board.check(column, row)
    if check_piece.color == @current_player.color.downcase
      puts "That space is occupied by your piece. Please enter another destination."
    else
      take_piece(@current_piece, column, row)
      return @current_piece
    end
    move_piece
  end

  # Runs when the player moves into an opponent's space.
  def take_piece(piece, column, row)
    lost_piece = @board.check(column, row)
    ensure_correct_move(@current_piece, column, row)
    puts "#{current_player.color} has captured a #{lost_piece.color} #{lost_piece.class}." 
  end

  # Makes sure pieces can only make legal moves. Also controls pawn movement
  # based on #pawn_diagonal.
  def ensure_correct_move(piece, column, row)
    if !piece.move_possible?(piece, column, row)
      puts "That move is not possible."
    elsif piece.move_possible?(piece, column, row)
      if piece.is_a?(Pawn) && pawn_diagonal?(piece, column, row)
        make_legal_move(piece, column, row)
        return piece
      elsif piece.is_a?(Pawn) && !pawn_diagonal?(piece, column, row)
        alternate_pawn_moves(piece, column, row)
        return piece
      elsif piece.is_a?(Bishop)
        block_bishop(piece, column, row)
        make_legal_move(piece, column, row)
        return piece
      else
        make_legal_move(piece, column, row)
        return piece
      end
    end
    move_piece
  end

  def block_bishop(piece, column, row)
    count = 1
    c = piece.column
    r = piece.row
    if column > c && row > r
      until count == column
        c += 1
        r += 1
        check_piece = @board.check(c, r)
        if check_piece != "___"
          puts "There is a piece blocking your move.  Enter another destination."
        end
        count += 1
      end
    elsif column > c && row < r
      until count == column
        c += 1
        r -= 1
        check_piece = @board.check(c, r)
        if check_piece != "___"
          puts "There is a piece blocking your move.  Enter another destination."
        end
        count += 1
      end
    elsif column < c && row < r
      until count == column
        c -= 1
        r -= 1
        check_piece = @board.check(c, r)
        if check_piece != "___"
          puts "There is a piece blocking your move.  Enter another destination."
        end
        count += 1
      end
    elsif column < c && row > r
      until count == column
        c -= 1
        r += 1
        check_piece = @board.check(c, r)
        if check_piece != "___"
          puts "There is a piece blocking your move.  Enter another destination."
        end
        count += 1
      end
    end
  end

  # The class method #move_possible is bypassed and this method is used instead
  # if the piece is a pawn that can't make any diagonal moves.
  def alternate_pawn_moves(piece, column, row)
    if piece.color == "white"
      if column - piece.column == 1 && piece.row == row
        make_legal_move(piece, column, row)
        return piece
      elsif piece.column == 1 && column - piece.column == 2 && piece.row == row
        make_legal_move(piece, column, row)
        return piece
      else
        puts "That move is not possible."
      end
    elsif piece.color == "black"
      if piece.column - column == 1 && piece.row == row
        make_legal_move(piece, column, row)
        return piece
      elsif piece.column == 6 && piece.column - column == 2 && piece.row == row
        make_legal_move(piece, column, row)
        return piece
      else
        puts "That move is not possible."
      end
    end
  end

  # Checks pieces diagonal to pawns to determine if the pawn is allowed to move
  # diagonally to capture them.  Returns true if so and false if not.
  def pawn_diagonal?(piece, column, row)
    if piece.color == "white" && !@board.space_open?(piece.column + 1, piece.row + 1) && 
      @board.check(piece.column + 1, piece.row + 1) != nil &&
      @board.check(piece.column + 1, piece.row + 1).color == "black" &&
      @board.space_open?(piece.column + 1, piece.row - 1)
      if @board.check(piece.column + 1, piece.row + 1) == @board.check(column, row)
        return true 
      else
        return false
      end
    elsif piece.color == "white" && !@board.space_open?(piece.column + 1, piece.row - 1) &&
      @board.check(piece.column + 1, piece.row - 1) != nil &&
      @board.check(piece.column + 1, piece.row - 1).color == "black" &&
      @board.space_open?(piece.column + 1, piece.row + 1)
      if @board.check(piece.column + 1, piece.row - 1) == @board.check(column, row)
        return true 
      else
        return false
      end
    elsif piece.color == "white" && @board.space_open?(piece.column + 1, piece.row + 1) && 
      @board.space_open?(piece.column + 1, piece.row - 1)
      return false
    elsif piece.color == "black" && !@board.space_open?(piece.column - 1, piece.row + 1) && 
      @board.check(piece.column - 1, piece.row + 1) != nil &&
      @board.check(piece.column - 1, piece.row + 1).color == "white" &&
      @board.space_open?(piece.column - 1, piece.row - 1)
      if @board.check(piece.column - 1, piece.row + 1) == @board.check(column, row)
        return true 
      else
        return false
      end
    elsif piece.color == "black" && !@board.space_open?(piece.column - 1, piece.row - 1) &&
      @board.check(piece.column - 1, piece.row - 1) != nil &&
      @board.check(piece.column - 1, piece.row - 1).color == "white" &&
      @board.space_open?(piece.column - 1, piece.row + 1)
      if @board.check(piece.column - 1, piece.row - 1) == @board.check(column, row)
        return true 
      else
        return false
      end
    elsif piece.color == "black" && @board.space_open?(piece.column - 1, piece.row + 1) && 
      @board.space_open?(piece.column - 1, piece.row - 1)
      return false
    end
    return false
  end

  def make_legal_move(piece, column, row)
    @board.empty_space(@initial_column, @initial_row)
    @board.move(piece, column, row)
  end

  # Translates the user input into appropriate row on the board.
  def translate_row(move, row)
    case move[0]
    when "a"
      row = 0
    when "b"
      row = 1
    when "c"
      row = 2
    when "d"
      row = 3
    when "e"
      row = 4
    when "f"
      row = 5
    when "g"
      row = 6
    when "h"
      row = 7
    end
  end

  # Translates the user input into appropriate column on the board.
  def translate_column(move, column)
    column = (move[1].to_i) - 1
  end
end

class Player

  attr_accessor :color

  def initialize(color)
    @color = color
  end
end

game = Chess.new
game.start_game
