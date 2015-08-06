require_relative 'board'
require_relative 'piece'

class Chess

  attr_accessor :player1, :player2, :current_player, :current_piece, :board

  def initialize
    @player1 = Player.new("White")
    @player2 = Player.new("Black")
    @current_player = player1
    @current_piece = nil
    @board = Board.new
  end

  def start_game
    display_intro
    game_turn
  end

  def game_turn
    @board.display_board
    select_piece
    move_piece
    @board.display_board
  end

  def display_intro
    puts "Welcome to Chess!"
    puts "Player 1 will be #{player1.color} and Player 2 will be #{player2.color}."
    puts ""
    puts "To enter your move, please enter the letter/number combo (e.g. b4)"
    puts "of the piece you would like to move. Next, enter the letter/number"
    puts "combo of the location you would like to move to."
  end

  def select_piece
    move = "99"
    column = 99
    row = 99
    until ('a'..'h').include?(move[0]) && ('1'..'8').include?(move[1]) && \
          move.length == 2 && !@board.space_open?(column, row)
      print "#{@current_player.color}, please select a piece to move: "
      move = gets.chomp
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
      column = (move[1].to_i) - 1
      if !('a'..'h').include?(move[0]) || !('1'..'8').include?(move[1]) || move.length != 2
        puts "That is not a valid entry.  Please enter a letter/number combo (e.g. d3)."
      elsif @board.space_open?(column, row)
        puts "You chose an empty space.  Please choose a space that contains a piece."
      end
    end
    @current_piece = @board.check(column, row)
    @board.empty_space(column, row)
  end

  def move_piece
    move = "99"
    column = 99
    row = 99
    until ('a'..'h').include?(move[0]) && ('1'..'8').include?(move[1]) && \
          move.length == 2 && @board.space_open?(column, row)
      print "#{@current_player.color}, please select a destination letter/number combo: "
      move = gets.chomp
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
      column = (move[1].to_i) - 1 
      if !('a'..'h').include?(move[0]) || !('1'..'8').include?(move[1]) || move.length != 2
        puts "That is not a valid entry.  Please enter a letter/number combo (e.g. d3)."
      elsif !@board.space_open?(column, row)
        # Add piece-taking code here later.
        puts "You chose an occupied space.  Please choose an open space."
      end
    end
    @board.move(@current_piece, column, row)
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
