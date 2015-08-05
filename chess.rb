require './lib/board'
require './lib/piece'

class Chess

  attr_accessor :player1, :player2, :current_player, :board

  def initialize
    @player1 = Player.new("White")
    @player2 = Player.new("Black")
    @current_player = player1
    @board = Board.new
  end

  def start_game
    display_intro
    game_turn
  end

  def game_turn
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

end

class Player

  attr_accessor :color

  def initialize(color)
    @color = color
  end

end

game = Chess.new
game.start_game
