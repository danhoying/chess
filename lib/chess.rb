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
    @en_passant = []
    @in_check = false
    @check_piece = []
    @white_king_moves = 0
    @left_white_rook_moves = 0
    @right_white_rook_moves = 0
    @black_king_moves = 0
    @left_black_rook_moves = 0
    @right_black_rook_moves = 0
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
      if castling_possible?(@board)
        get_castling_input(@board)
      else
        select_piece
        move_piece
      end
      if @en_passant != []
        en_passant_cancel(@current_piece)
      end
      display_past_move
      switch_players
    end
  end

  # Asks the player to type 'castle' to perform castling.  If not, continue turn
  # as usual.
  def get_castling_input(board)
    puts ""
    print "#{@current_player.color}, type 'castle' if you would like to perform castling: "
    input = gets.chomp
    if input.include?('castle')
      perform_castling(board)
    else
      select_piece
      move_piece
    end
  end

  def get_castling_choice(board)
    puts ""
    puts "#{@current_player.color}, you can perform short castling or long castling."
    print "Please type 'short' to do short castling or 'long' to do long castling: "
    input = gets.chomp
  end

  # Determines if all castling conditions are met. If so, changes an instance
  # variable to true and returns true. Past movement is determined by the
  # #check_for_castling_movement method.
  def castling_possible?(board)
    if @current_player.color.downcase == "white"
      if board.space_open?(0, 1) && board.space_open?(0, 2) && board.space_open?(0, 3) &&
          @white_king_moves == 0 && @left_white_rook_moves == 0 && 
          board.space_open?(0, 5) && board.space_open?(0, 6) &&
          @white_king_moves == 0 && @right_white_rook_moves == 0
        @white_castle_long = true
        @white_castle_short = true
        return true
      elsif board.space_open?(0, 1) && board.space_open?(0, 2) && board.space_open?(0, 3) &&
          @white_king_moves == 0 && @left_white_rook_moves == 0
        @white_castle_long = true
        return true
      elsif board.space_open?(0, 5) && board.space_open?(0, 6) &&
          @white_king_moves == 0 && @right_white_rook_moves == 0
        @white_castle_short = true
        return true
      end
    elsif @current_player.color.downcase == "black"
      if board.space_open?(7, 1) && board.space_open?(7, 2) && board.space_open?(7, 3) &&
          @black_king_moves == 0 && @left_black_rook_moves == 0 && 
          board.space_open?(7, 5) && board.space_open?(7, 6) &&
          @black_king_moves == 0 && @right_black_rook_moves == 0
        @black_castle_short = true
        @black_castle_long = true
        return true
      elsif board.space_open?(7, 1) && board.space_open?(7, 2) && board.space_open?(7, 3) &&
          @black_king_moves == 0 && @left_black_rook_moves == 0
        @black_castle_long = true
        return true
      elsif board.space_open?(7, 5) && board.space_open?(7, 6) &&
          @black_king_moves == 0 && @right_black_rook_moves == 0
        @black_castle_short = true
        return true
      end
    end
    @white_castle_long = false
    @white_castle_short = false
    @black_castle_long = false
    @black_castle_short = false
    return false
  end

  # Method that determines whether to perform long castling or short castling
  # and moves the pieces accordingly. Handles the edge case of having both
  # castling methods possible at once and asks for the player's choice.
  def perform_castling(board)
    if @white_castle_long == true && @white_castle_short == true
      input = get_castling_choice(board)
      if input.include?('long')
        white_king = board.check(0, 4)
        white_left_rook = board.check(0, 0)
        board.move(white_king, 0, 2)
        board.move(white_left_rook, 0, 3)
        board.empty_space(0, 4)
        board.empty_space(0, 0)
        @white_king_moves = 1
        @white_castle_long = false
      elsif input.include?('short')
        white_king = board.check(0, 4)
        white_right_rook = board.check(0, 7)
        board.move(white_king, 0, 6)
        board.move(white_right_rook, 0, 5)
        board.empty_space(0, 7)
        board.empty_space(0, 4)
        @white_king_moves = 1
        @white_castle_short = false
      end
    elsif @white_castle_long == true
      white_king = board.check(0, 4)
      white_left_rook = board.check(0, 0)
      board.move(white_king, 0, 2)
      board.move(white_left_rook, 0, 3)
      board.empty_space(0, 4)
      board.empty_space(0, 0)
      @white_king_moves = 1
      @white_castle_long = false
    elsif @white_castle_short == true
      white_king = board.check(0, 4)
      white_right_rook = board.check(0, 7)
      board.move(white_king, 0, 6)
      board.move(white_right_rook, 0, 5)
      board.empty_space(0, 7)
      board.empty_space(0, 4)
      @white_king_moves = 1
      @white_castle_short = false

    elsif @black_castle_long == true && @black_castle_short == true
      input = get_castling_choice(board)
      if input.include?('long')
        black_king = board.check(7, 4)
        black_left_rook = board.check(7, 0)
        board.move(black_king, 7, 2)
        board.move(black_left_rook, 7, 3)
        board.empty_space(7, 4)
        board.empty_space(7, 0)
        @black_king_moves = 1
        @black_castle_long == false
      elsif input.include?('short')
        black_king = board.check(7, 4)
        black_right_rook = board.check(7, 7)
        board.move(black_king, 7, 6)
        board.move(black_right_rook, 7, 5)
        board.empty_space(7, 7)
        board.empty_space(7, 4)
        @black_king_moves = 1
        @black_castle_short == false
      end
    elsif @black_castle_long == true
      black_king = board.check(7, 4)
      black_left_rook = board.check(7, 0)
      board.move(black_king, 7, 2)
      board.move(black_left_rook, 7, 3)
      board.empty_space(7, 4)
      board.empty_space(7, 0)
      @black_king_moves = 1
      @black_castle_long == false
    elsif @black_castle_short == true
      black_king = board.check(7, 4)
      black_right_rook = board.check(7, 7)
      board.move(black_king, 7, 6)
      board.move(black_right_rook, 7, 5)
      board.empty_space(7, 7)
      board.empty_space(7, 4)
      @black_king_moves = 1
      @black_castle_short == false
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

  # Asks current player to select a piece to move. Also allows player to type
  # 'save' to save and quit the game.  Checks if the selected piece is of the
  # correct color and if it is possible to move.  If not, allows the player to
  # select a new piece.
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

  # Checks for impossiblity of movement for each type of piece.
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
    if piece.is_a?(Pawn) && piece.color == "white" && @en_passant == [] &&
      @board.check(column + 1, row + 1) != nil &&
      @board.check(column + 1, row - 1) != nil &&
      !@board.space_open?(column + 1, row) && @board.space_open?(column + 1, row + 1) && 
        @board.space_open?(column + 1, row - 1)
      puts "A move is not possible here. Please select another piece."
      select_piece
    elsif piece.is_a?(Pawn) && piece.color == "black" && @en_passant == [] &&
      @board.check(column -1, row + 1) != nil &&
      @board.check(column -1, row - 1) != nil &&
      !@board.space_open?(column - 1, row) && @board.space_open?(column - 1, row + 1) && 
        @board.space_open?(column - 1, row - 1)
      puts "A move is not possible here. Please select another piece."
      select_piece
    end
  end

  # Runs through all possible moves and determines if the current piece is 
  # being blocked and cannot move. If so, allows the player to choose a new
  # piece. Also checks for any pieces in the way of possible moves and adds 
  # them to an array @bishop_path_pieces.
  def bishop_impossible(piece, column, row)
    if piece.is_a?(Bishop)
      nearby = []
      total_possible = []
      @bishop_path_pieces = []
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
          if move.all? { |value| value >= 0 } && move.all? { |value| value <= 7 }
            total_possible << move
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
        total_possible.each do |j|
          if @board.check(j[0], j[1]) != "___" && !@bishop_path_pieces.include?(j)
            @bishop_path_pieces << j
          end
        end
      end   
    end
  end

  # Runs through all possible moves and determines if the current piece is 
  # being blocked and cannot move. If so, allows the player to choose a new
  # piece. Also checks for any pieces in the way of possible moves and adds 
  # them to an array @rook_path_pieces.
  def rook_impossible(piece, column, row)
    if piece.is_a?(Rook) 
      nearby = []
      total_possible = []
      @rook_path_pieces = []
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
          if move.all? { |value| value >= 0 } && move.all? { |value| value <= 7 }
            total_possible << move
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
        total_possible.each do |j|
          if @board.check(j[0], j[1]) != "___" && !@rook_path_pieces.include?(j)
            @rook_path_pieces << j
          end
        end
      end
    end
  end

  # Runs through all possible moves and determines if the current piece is 
  # being blocked and cannot move. If so, allows the player to choose a new
  # piece.
  def knight_impossible(piece, column, row)
    if piece.is_a?(Knight)
      items = 0
      c = piece.column
      r = piece.row
      possible_moves = [[c + 2, r + 1], [c + 2, r - 1], [c - 2, r + 1], [c - 2, r - 1],
                      [c + 1, r + 2], [c - 1, r + 2], [c + 1, r - 2], [c - 1, r - 2]]
      possible_moves.each do |move|
        if move.all? { |value| value >= 0 } && move.all? { |value| value <= 7 } && 
            @board.check(move[0], move[1]) != "___" && 
            @board.check(move[0], move[1]).color == piece.color
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

  # Runs through all possible moves and determines if the current piece is 
  # being blocked and cannot move. If so, allows the player to choose a new
  # piece. Also checks for any pieces in the way of possible moves and adds 
  # them to an array @queen_path_pieces.
  def queen_impossible(piece, column, row)
    if piece.is_a?(Queen) 
      nearby = []
      total_possible = []
      @queen_path_pieces = []
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
          if move.all? { |value| value >= 0 } && move.all? { |value| value <= 7 }
            total_possible << move
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
        total_possible.each do |j|
          if @board.check(j[0], j[1]) != "___" && !@queen_path_pieces.include?(j)
            @queen_path_pieces << j
          end
        end
      end
    end
  end

  # Runs through all possible moves and determines if the current piece is 
  # being blocked and cannot move. If so, allows the player to choose a new
  # piece.
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
  # Forbids the player from capturing own piece and checks if the chosen move
  # is valid.
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
    puts ""
    puts "~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~"
    puts "#{current_player.color} has captured a #{lost_piece.color} #{lost_piece.class}!" 
    puts "~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~"
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
        if @en_passant != []
          en_passant_move(piece, column, row)
        end
        return piece
      elsif piece.is_a?(Bishop) && !block_bishop?(piece, column, row)
        make_legal_move(piece, column, row)
        return piece
      elsif piece.is_a?(Rook) && !block_rook?(piece, column, row)
        make_legal_move(piece, column, row)
        return piece
      elsif piece.is_a?(Queen) && !block_queen?(piece, column, row)
        make_legal_move(piece, column, row)
        return piece  
      elsif piece.is_a?(Knight)
        make_legal_move(piece, column, row)
        return piece
      elsif piece.is_a?(King)
        if @in_check == true
          puts "That move puts your king into check!  Choose another move."
        else
          make_legal_move(piece, column, row)
          return piece
        end
      end
    end
    move_piece
  end

  # Returns true if white pawn puts king into check, false if not. 
  def white_pawn_check?(piece, column, row)
    if piece.is_a?(Pawn) && piece.color == "white"
      c = piece.column
      r = piece.row
      possible = []
      check_sides = [[c + 1, r - 1], [c + 1, r + 1]]
      check_sides.each do |check|
        if check.all? { |value| value >= 0 } && check.all? { |value| value <= 7 }
          possible << check
        end
      end
      possible.each do |item|
        if @board.check(item[0], item[1]) != "___" && 
            @board.check(item[0], item[1]).color != piece.color &&
            @board.check(item[0], item[1]).is_a?(King)
          return true
        end
      end
    end
    return false
  end

  # Returns true if black pawn puts king into check, false if not.
  def black_pawn_check?(piece, column, row)
    if piece.is_a?(Pawn) && piece.color == "black"
      c = piece.column
      r = piece.row
      possible = []
      check_sides = [[c - 1, r - 1], [c - 1, r + 1]]
      check_sides.each do |check|
        if check.all? { |value| value >= 0 } && check.all? { |value| value <= 7 }
          possible << check
        end
      end
      possible.each do |item|
        if @board.check(item[0], item[1]) != "___" && 
            @board.check(item[0], item[1]).color != piece.color &&
            @board.check(item[0], item[1]).is_a?(King)
          return true
        end
      end
    end
    return false
  end

  def knight_check?(piece, column, row)
    if piece.is_a?(Knight)
      c = piece.column
      r = piece.row
      possible = []
      possible_moves = [[c + 2, r + 1], [c + 2, r - 1], [c - 2, r + 1], [c - 2, r - 1],
                        [c + 1, r + 2], [c - 1, r + 2], [c + 1, r - 2], [c - 1, r - 2]]
      possible_moves.each do |move|
        if move.all? { |value| value >= 0 } && move.all? { |value| value <= 7 }
          possible << move
        end
      end
      possible.each do |item|
        if @board.check(item[0], item[1]) != "___" && 
            @board.check(item[0], item[1]).color != piece.color &&
            @board.check(item[0], item[1]).is_a?(King)
          return true
        end
      end
    end
    return false
  end

  # Returns true if bishop puts king into check, false if not.
  def bishop_check?(piece, column, row)
    if piece.is_a?(Bishop)
      blocking_up_right = false
      blocking_up_left = false
      blocking_down_left = false
      blocking_down_right = false
      count_up_right = 1
      count_up_left = 1
      count_down_left = 1
      count_down_right = 1

      until column + count_up_right > 7 && row + count_up_right > 7
        if column + count_up_right <= 7 && row + count_up_right <= 7
          up_right = @board.check(column + count_up_right, row + count_up_right)
          if up_right != "___" && !up_right.is_a?(King)
            blocking_up_right = true
          elsif up_right.is_a?(King) && up_right.color != piece.color &&
              blocking_up_right == false
            return true
          end
        end
        count_up_right += 1
      end

      until column + count_up_left > 7 && row - count_up_left < 0
        if column + count_up_left <= 7 && row - count_up_left >= 0
          up_left = @board.check(column + count_up_left, row - count_up_left)
          if up_left != "___" && !up_left.is_a?(King)
            blocking_up_left = true
          elsif up_left.is_a?(King) && up_left.color != piece.color &&
              blocking_up_left == false
            return true
          end
        end
        count_up_left += 1
      end

      until column - count_down_left < 0 && row - count_down_left < 0
        if column - count_down_left >= 0 && row - count_down_left >= 0
          down_left = @board.check(column - count_down_left, row - count_down_left) 
          if down_left != "___" && !down_left.is_a?(King)
            blocking_down_left = true
          elsif down_left.is_a?(King) && down_left.color != piece.color &&
              blocking_down_left == false
            return true
          end
        end
        count_down_left += 1
      end

      until column - count_down_right < 0 && row + count_down_right > 7
        if column - count_down_right >= 0 && row + count_down_right <= 7
          down_right = @board.check(column - count_down_right, row + count_down_right) 
          if down_right != "___" && !down_right.is_a?(King)
            blocking_down_right = true
          elsif down_right.is_a?(King) && down_right.color != piece.color &&
              blocking_down_right == false
            return true
          end
        end
        count_down_right += 1
      end
    end
    return false
  end

  # Returns true if rook puts king into check, false if not.
  def rook_check?(piece, column, row)
    if piece.is_a?(Rook)
      blocking_up = false
      blocking_left = false
      blocking_down = false
      blocking_right = false
      count_up = 1
      count_left = 1
      count_down = 1
      count_right = 1

      until column + count_up > 7 
        if column + count_up <= 7
          up = @board.check(column + count_up, row)
          if up != "___" && !up.is_a?(King)
            blocking_up = true
          elsif up.is_a?(King) && up.color != piece.color &&
              blocking_up == false
            return true
          end
        end
        count_up += 1
      end

      until row - count_left < 0
        if row - count_left >= 0
          left = @board.check(column, row - count_left)
          if left != "___" && !left.is_a?(King)
            blocking_left = true
          elsif left.is_a?(King) && left.color != piece.color &&
              blocking_left == false
            return true
          end
        end
        count_left += 1
      end

      until column - count_down < 0
        if column - count_down >= 0 
          down = @board.check(column - count_down, row) 
          if down != "___" && !down.is_a?(King)
            blocking_down = true
          elsif down.is_a?(King) && down.color != piece.color &&
              blocking_down == false
            return true
          end
        end
        count_down += 1
      end

      until row + count_right > 7
        if row + count_right <= 7
          right = @board.check(column, row + count_right) 
          if right != "___" && !right.is_a?(King)
            blocking_right = true
          elsif right.is_a?(King) && right.color != piece.color &&
              blocking_right == false
            return true
          end
        end
        count_right += 1
      end
    end
    return false
  end

  # Returns true if queen puts king into check, false if not.
  def queen_check?(piece, column, row)
    if piece.is_a?(Queen)
      blocking_up_right = false
      blocking_up_left = false
      blocking_down_left = false
      blocking_down_right = false
      count_up_right = 1
      count_up_left = 1
      count_down_left = 1
      count_down_right = 1
      
      until column + count_up_right > 7 && row + count_up_right > 7
        if column + count_up_right <= 7 && row + count_up_right <= 7
          up_right = @board.check(column + count_up_right, row + count_up_right)
          if up_right != "___" && !up_right.is_a?(King)
            blocking_up_right = true
          elsif up_right.is_a?(King) && up_right.color != piece.color &&
              blocking_up_right == false
            return true
          end
        end
        count_up_right += 1
      end

      until column + count_up_left > 7 && row - count_up_left < 0
        if column + count_up_left <= 7 && row - count_up_left >= 0
          up_left = @board.check(column + count_up_left, row - count_up_left)
          if up_left != "___" && !up_left.is_a?(King)
            blocking_up_left = true
          elsif up_left.is_a?(King) && up_left.color != piece.color &&
              blocking_up_left == false
            return true
          end
        end
        count_up_left += 1
      end

      until column - count_down_left < 0 && row - count_down_left < 0
        if column - count_down_left >= 0 && row - count_down_left >= 0
          down_left = @board.check(column - count_down_left, row - count_down_left) 
          if down_left != "___" && !down_left.is_a?(King)
            blocking_down_left = true
          elsif down_left.is_a?(King) && down_left.color != piece.color &&
              blocking_down_left == false
            return true
          end
        end
        count_down_left += 1
      end

      until column - count_down_right < 0 && row + count_down_right > 7
        if column - count_down_right >= 0 && row + count_down_right <= 7
          down_right = @board.check(column - count_down_right, row + count_down_right) 
          if down_right != "___" && !down_right.is_a?(King)
            blocking_down_right = true
          elsif down_right.is_a?(King) && down_right.color != piece.color &&
              blocking_down_right == false
            return true
          end
        end
        count_down_right += 1
      end

      blocking_up = false
      blocking_left = false
      blocking_down = false
      blocking_right = false
      count_up = 1
      count_left = 1
      count_down = 1
      count_right = 1

      until column + count_up > 7 
        if column + count_up <= 7
          up = @board.check(column + count_up, row)
          if up != "___" && !up.is_a?(King)
            blocking_up = true
          elsif up.is_a?(King) && up.color != piece.color &&
              blocking_up == false
            return true
          end
        end
        count_up += 1
      end

      until row - count_left < 0
        if row - count_left >= 0
          left = @board.check(column, row - count_left)
          if left != "___" && !left.is_a?(King)
            blocking_left = true
          elsif left.is_a?(King) && left.color != piece.color &&
              blocking_left == false
            return true
          end
        end
        count_left += 1
      end

      until column - count_down < 0
        if column - count_down >= 0 
          down = @board.check(column - count_down, row) 
          if down != "___" && !down.is_a?(King)
            blocking_down = true
          elsif down.is_a?(King) && down.color != piece.color &&
              blocking_down == false
            return true
          end
        end
        count_down += 1
      end

      until row + count_right > 7
        if row + count_right <= 7
          right = @board.check(column, row + count_right) 
          if right != "___" && !right.is_a?(King)
            blocking_right = true
          elsif right.is_a?(King) && right.color != piece.color &&
              blocking_right == false
            return true
          end
        end
        count_right += 1
      end
    end
    return false
  end

  # Determines if the chosen destination space is beyond the location of a
  # piece in @bishop_path_pieces and returns true if so, false if not. This
  # method prevents "jumping" over pieces to reach the destination square.  
  def block_bishop?(piece, column, row)  
    @bishop_path_pieces.each do |item|
      if item[0] - piece.column > 0 && item[1] - piece.row > 0 # up right
        if column > item[0] && row > item[1]
          puts "There is a piece blocking your move.  Enter another destination."
          return true
        end
      elsif item[0] - piece.column > 0 && item[1] - piece.row < 0 # up left
        if column > item[0] && row < item[1]
          puts "There is a piece blocking your move.  Enter another destination."
          return true
        end
      elsif item[0] - piece.column < 0 && item[1] - piece.row > 0 # down right
        if column < item[0] && row > item[1]
          puts "There is a piece blocking your move.  Enter another destination."
          return true
        end
      elsif item[0] - piece.column < 0 && item[1] - piece.row < 0 # down left
        if column < item[0] && row < item[1]
          puts "There is a piece blocking your move.  Enter another destination."
          return true
        end
      end
    end
    return false
  end

  # Determines if the chosen destination space is beyond the location of a
  # piece in @rook_path_pieces and returns true if so, false if not. This
  # method prevents "jumping" over pieces to reach the destination square.  
  def block_rook?(piece, column, row)
    @rook_path_pieces.each do |item|
      if item[0] - piece.column > 0 && item[1] - piece.row == 0 # up
        if column > item[0] && row == item[1]
          puts "There is a piece blocking your move.  Enter another destination."
          return true
        end
      elsif item[0] - piece.column == 0 && item[1] - piece.row < 0 # left
        if column == item[0] && row < item[1]
          puts "There is a piece blocking your move.  Enter another destination."
          return true
        end
      elsif item[0] - piece.column < 0 && item[1] - piece.row == 0 # down 
        if column < item[0] && row == item[1]
          puts "There is a piece blocking your move.  Enter another destination."
          return true
        end
      elsif item[0] - piece.column == 0 && item[1] - piece.row > 0 # right
        if column == item[0] && row > item[1]
          puts "There is a piece blocking your move.  Enter another destination."
          return true
        end
      end
    end
    return false
  end

  # Determines if the chosen destination space is beyond the location of a
  # piece in @queen_path_pieces and returns true if so, false if not. This
  # method prevents "jumping" over pieces to reach the destination square.  
  def block_queen?(piece, column, row)
    @queen_path_pieces.each do |item|
      if item[0] - piece.column > 0 && item[1] - piece.row > 0 # up right
        if column > item[0] && row > item[1]
          puts "There is a piece blocking your move.  Enter another destination."
          return true
        end
      elsif item[0] - piece.column > 0 && item[1] - piece.row < 0 # up left
        if column > item[0] && row < item[1]
          puts "There is a piece blocking your move.  Enter another destination."
          return true
        end
      elsif item[0] - piece.column < 0 && item[1] - piece.row > 0 # down right
        if column < item[0] && row > item[1]
          puts "There is a piece blocking your move.  Enter another destination."
          return true
        end
      elsif item[0] - piece.column < 0 && item[1] - piece.row < 0 # down left
        if column < item[0] && row < item[1]
          puts "There is a piece blocking your move.  Enter another destination."
          return true
        end
      elsif item[0] - piece.column > 0 && item[1] - piece.row == 0 # up
        if column > item[0] && row == item[1]
          puts "There is a piece blocking your move.  Enter another destination."
          return true
        end
      elsif item[0] - piece.column == 0 && item[1] - piece.row < 0 # left
        if column == item[0] && row < item[1]
          puts "There is a piece blocking your move.  Enter another destination."
          return true
        end
      elsif item[0] - piece.column < 0 && item[1] - piece.row == 0 # down 
        if column < item[0] && row == item[1]
          puts "There is a piece blocking your move.  Enter another destination."
          return true
        end
      elsif item[0] - piece.column == 0 && item[1] - piece.row > 0 # right
        if column == item[0] && row > item[1]
          puts "There is a piece blocking your move.  Enter another destination."
          return true
        end
      end
    end
    return false
  end

  # The class method #move_possible is bypassed and this method is used instead
  # if the piece is a pawn that can't make any diagonal moves.
  def alternate_pawn_moves(piece, column, row)
    if piece.color == "white"
      if column - piece.column == 1 && piece.row == row && @board.space_open?(column, row)
        make_legal_move(piece, column, row)
        return piece
      elsif piece.column == 1 && column - piece.column == 2 && piece.row == row &&
          @board.space_open?(column, row) && @board.space_open?(column - 1, row)
        make_legal_move(piece, column, row)
        if en_passant_white?(piece)
          @en_passant = piece
        end
        return piece
      elsif @en_passant != [] && en_passant_capture?(piece, column, row)
        return piece
      else
        puts "That move is not possible."
      end
    elsif piece.color == "black"
      if piece.column - column == 1 && piece.row == row && @board.space_open?(column, row)
        make_legal_move(piece, column, row)
        return piece
      elsif piece.column == 6 && piece.column - column == 2 && piece.row == row &&
          @board.space_open?(column, row) && @board.space_open?(column + 1, row)
        make_legal_move(piece, column, row)
        if en_passant_black?(piece)
          @en_passant = piece
        end
        return piece
      elsif @en_passant != [] && en_passant_capture?(piece, column, row)
        return piece
      else
        puts "That move is not possible."
      end
    end
    move_piece
  end

  # Checks if a white piece is at risk for being captured en passant, and 
  # returns true if so.
  def en_passant_white?(piece)
    c = piece.column
    r = piece.row
    possible = []
    neighbors = []
    check_sides = [[c, r - 1], [c, r + 1]]
    check_sides.each do |check|
      if check.all? { |value| value >= 0 } && check.all? { |value| value <= 7 }
        possible << check
      end
    end
    possible.each do |item|
      if @board.check(item[0], item[1]) != "___" && 
          @board.check(item[0], item[1]).color == "black"
          return true
      end
    end
    return false
  end

  # Checks if a black piece is at risk for being captured en passant, and 
  # returns true if so.
  def en_passant_black?(piece)
    c = piece.column
    r = piece.row
    possible = []
    neighbors = []
    check_sides = [[c, r - 1], [c, r + 1]]
    check_sides.each do |check|
      if check.all? { |value| value >= 0 } && check.all? { |value| value <= 7 }
        possible << check
      end
    end
    possible.each do |item|
      if @board.check(item[0], item[1]) != "___" && 
          @board.check(item[0], item[1]).color == "white"
          return true
      end
    end
    return false
  end

  # Checks if a piece has moved into the correct position to capture en passant.
  def en_passant_capture?(piece, column, row)
    if piece.column == @en_passant.column && piece.row - @en_passant.row == 1 ||
        @en_passant.row - piece.row == 1
      if piece.color == "black" && column == @en_passant.column - 1 && row == @en_passant.row
        return true
      elsif piece.color == "white" && column - @en_passant.column == 1 && row == @en_passant.row
        return true
      end
    end 
    return false
  end

  # Performs the en passant capture if possible.
  def en_passant_move(piece, column, row)
    if @en_passant != [] && piece.color == "white" && @en_passant.color == "black"
      if en_passant_capture?(piece, column, row)
        @board.move(piece, column, row)
        @board.empty_space(@initial_column, @initial_row)
        @board.empty_space(@en_passant.column, @en_passant.row)
        puts ""
        puts "~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~"
        puts "#{current_player.color} has captured a #{@en_passant.color} #{@en_passant.class}!" 
        puts "~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~"
        @en_passant = []
        return piece
      end
    elsif @en_passant != [] && piece.color == "black" && @en_passant.color == "white"
      if en_passant_capture?(piece, column, row)
        @board.move(piece, column, row)
        @board.empty_space(@initial_column, @initial_row)
        @board.empty_space(@en_passant.column, @en_passant.row)
        puts ""
        puts "~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~"
        puts "#{current_player.color} has captured a #{@en_passant.color} #{@en_passant.class}!" 
        puts "~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~"
        @en_passant = []
        return piece
      end
    end
  end

  # Ensures that a piece can be captured en passant on the subsequent turn only.
  def en_passant_cancel(piece)
    if @en_passant != [] && @en_passant.color == piece.color
      @en_passant
    elsif @en_passant != [] && @en_passant.color != piece.color
      @en_passant = []
    end
  end

  # Checks pieces diagonal to pawns to determine if the pawn is allowed to move
  # diagonally to capture them.  Returns true if so and false if not.
  def pawn_diagonal?(piece, column, row)
    if piece.color == "white" && !@board.space_open?(piece.column + 1, piece.row + 1) &&
        !@board.space_open?(piece.column + 1, piece.row - 1) &&
        @board.check(piece.column + 1, piece.row + 1) != nil &&
        @board.check(piece.column + 1, piece.row - 1) != nil &&
        @board.check(piece.column + 1, piece.row + 1).color == "black" &&
        @board.check(piece.column + 1, piece.row - 1).color == "black"
      if column - piece.column == 1 && row - piece.row == 1
        return true 
      elsif column - piece.column == 1 && piece.row - row == 1
        return true
      end
    elsif piece.color == "white" && !@board.space_open?(piece.column + 1, piece.row + 1) && 
        @board.check(piece.column + 1, piece.row + 1) != nil &&
        @board.check(piece.column + 1, piece.row + 1).color == "black" &&
        @board.space_open?(piece.column + 1, piece.row - 1)
      if column - piece.column == 1 && row - piece.row == 1
        return true 
      end
    elsif piece.color == "white" && !@board.space_open?(piece.column + 1, piece.row - 1) &&
        @board.check(piece.column + 1, piece.row - 1) != nil &&
        @board.check(piece.column + 1, piece.row - 1).color == "black" &&
        @board.space_open?(piece.column + 1, piece.row + 1)
      if column - piece.column == 1 && piece.row - row == 1
        return true 
      end
    elsif piece.color == "white" && @board.space_open?(piece.column + 1, piece.row + 1) && 
        @board.space_open?(piece.column + 1, piece.row - 1)
      return false
    end

    if piece.color == "black" && !@board.space_open?(piece.column - 1, piece.row + 1) &&
        !@board.space_open?(piece.column - 1, piece.row - 1) &&
        @board.check(piece.column - 1, piece.row + 1) != nil &&
        @board.check(piece.column - 1, piece.row - 1) != nil &&
        @board.check(piece.column - 1, piece.row + 1).color == "white" &&
        @board.check(piece.column - 1, piece.row - 1).color == "white"
      if piece.column - column == 1 && row - piece.row == 1
        return true 
      elsif piece.column - column == 1 && piece.row - row == 1
        return true
      end
    elsif piece.color == "black" && !@board.space_open?(piece.column - 1, piece.row + 1) && 
        @board.check(piece.column - 1, piece.row + 1) != nil &&
        @board.check(piece.column - 1, piece.row + 1).color == "white" &&
        @board.space_open?(piece.column - 1, piece.row - 1)
      if piece.column - column == 1 && row - piece.row == 1
        return true 
      end
    elsif piece.color == "black" && !@board.space_open?(piece.column - 1, piece.row - 1) &&
        @board.check(piece.column - 1, piece.row - 1) != nil &&
        @board.check(piece.column - 1, piece.row - 1).color == "white" &&
        @board.space_open?(piece.column - 1, piece.row + 1)
      if piece.column - column == 1 && piece.row - row == 1
        return true 
      end
    elsif piece.color == "black" && @board.space_open?(piece.column - 1, piece.row + 1) && 
        @board.space_open?(piece.column - 1, piece.row - 1)
      return false
    end
    return false
  end

  # Gets player's choice for piece to promote to.
  def choose_promotion(piece, column, row)
    choice = 'p'
    puts ""
    puts "Congratulations, #{@current_player.color}, your pawn has been promoted!"
    puts "What would you like your promotion to be? Please enter"
    puts "q, r, k, or b for queen, rook, knight, or bishop, respectively."
    until choice.include?('q') || choice.include?('r') || choice.include?('k') ||
        choice.include?('b')
      puts "" 
      print "#{@current_player.color}, please select your promotion: "
      choice = gets.chomp
    end
    choice
  end

  # Promotes white pawns.
  def promote_white(piece, column, row, choice)
    case choice
    when 'q'
      piece = Queen.new("white", ("\u265B"), column, row)
    when 'r'
      piece = Rook.new("white", ("\u265C"), column, row)
    when 'k'
      piece = Knight.new("white", ("\u265E"), column, row)
    when 'b'
      piece = Bishop.new("white", ("\u265D"), column, row)
    end
  end

  # Promotes black pawns
  def promote_black(piece, column, row, choice)
    case choice
    when 'q'
      piece = Queen.new("black", ("\u2655"), column, row)
    when 'r'
      piece = Rook.new("black", ("\u2656"), column, row)
    when 'k'
      piece = Knight.new("black", ("\u2658"), column, row)
    when 'b'
      piece = Bishop.new("black", ("\u2657"), column, row)
    end
  end

  # Checks if current piece has moved to a location that puts the opponent's 
  # king in check.  If so, switches @in_check to true and displays a message.
  def verify_if_check_occurs(piece, column, row)
    @opponent = nil
    @current_player.color == "White" ? @opponent = "Black" : @opponent = "White"
    if white_pawn_check?(piece, column, row) || black_pawn_check?(piece, column, row) ||
        bishop_check?(piece, column, row) || rook_check?(piece, column, row) ||
        queen_check?(piece, column, row) || knight_check?(piece, column, row)
      @in_check = true
      @check_piece = piece
      if @in_check == true
        puts ""
        puts "~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~"
        puts "#{@current_player.color} has the #{@opponent} King in check!"
        puts "~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~"
      end
    else
      @in_check = false
    end
  end

  # Moves piece to destination square and empties previous position. If piece
  # is a pawn moving into the 8th rank, allows piece to be promoted.
  def make_legal_move(piece, column, row)
    @board.empty_space(@initial_column, @initial_row)
    @board.move(piece, column, row)
    check_for_castling_movement(piece)
    verify_if_check_occurs(piece, column, row)
    if piece.is_a?(Pawn) && piece.color == "white" && piece.column == 7
      choice = choose_promotion(piece, column, row)
      piece = promote_white(piece, column, row, choice)
      @board.move(piece, column, row)
      return piece
    elsif piece.is_a?(Pawn) && piece.color == "black" && piece.column == 0
      choice = choose_promotion(piece, column, row)
      piece = promote_black(piece, column, row, choice)
      @board.move(piece, column, row)
      return piece
    end
  end

  # Updates a counter for each rook and king if they are moved, thus invalidating
  # the ability to perform castling.
  def check_for_castling_movement(piece)
    if piece.is_a?(King) && piece.color == "white"
      @white_king_moves = 1
    elsif piece.is_a?(Rook) && piece.color == "white" && @initial_column == 0 &&
        @initial_row == 0
      @left_white_rook_moves = 1
    elsif piece.is_a?(Rook) && piece.color == "white" && @initial_column == 0 &&
        @initial_row == 7
      @right_white_rook_moves = 1

    elsif piece.is_a?(King) && piece.color == "black"
      @black_king_moves = 1
    elsif piece.is_a?(Rook) && piece.color == "black" && @initial_column == 7 &&
        @initial_row == 0
      @left_black_rook_moves = 1
    elsif piece.is_a?(Rook) && piece.color == "black" && @initial_column == 7 &&
        @initial_row == 7
      @right_black_rook_moves = 1
    end
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
