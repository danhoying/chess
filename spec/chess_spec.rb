require './lib/chess'

describe "Chess" do

  let(:game) { Chess.new }

  before :each do
      @board = Board.new
  end

  context "#start_game" do
    it "displays a welcome message" do
      expect(game.display_intro)
    end

    it "sets the current player to player1" do
      expect(game.current_player).to eql game.player1
    end

    it "displays the instructions" do
      expect(game.display_instructions)
    end
  end

  context "#game_turn" do
    it "switches players after each turn" do
      expect(game.current_player).to eql game.player1
      game.switch_players
      expect(game.current_player).to eql game.player2
    end

    it "gets the player's input" do
      allow(game).to receive(:gets).and_return('b1')
      expect(game.select_piece)
      allow(game).to receive(:gets).and_return('bb1')
      expect($stderr.puts "That is not a valid entry.  Please enter a letter/number combo (e.g. d2).")
      allow(game).to receive(:gets).and_return('3')
      expect($stderr.puts "That is not a valid entry.  Please enter a letter/number combo (e.g. d2).")
      allow(game).to receive(:gets).and_return('d9')
      expect($stderr.puts "That is not a valid entry.  Please enter a letter/number combo (e.g. d2).")
      allow(game).to receive(:gets).and_return('j9')
      expect($stderr.puts "That is not a valid entry.  Please enter a letter/number combo (e.g. d2).")
    end
  end

  context "selecting a piece" do
    it "selects a piece" do
      allow(game).to receive(:gets).and_return('b1')
      expect(game.current_piece).to be_an_instance_of(Piece)
    end

    it "notifies the player when an empty square is selected" do
      allow(game).to receive(:gets).and_return('d4')
      expect(@board.space_open?(3, 3)).to eql true 
    end

    it "doesn't allow player to select opponent's piece" do
      @opponent = Player.new("black")
      expect(game.ensure_correct_color(game.current_piece))
      expect(@board.check_color?(game.current_piece.color, game.current_player.color)).to eql true
      expect($stderr.puts "You selected your opponent's piece. Try again.")
      expect(@board.check_color?(game.current_piece.color, @opponent.color)).to eql false
    end

    it "notifies the player when a pawn with no possible moves is selected." do
      @current_piece = Pawn.new("white", ("\u265F"), 1, 0)
      @opponent = Pawn.new("black", ("\u265F"), 6, 0)
      @board.move(@current_piece, 2, 0)
      @board.move(@opponent, 5, 0)
      @board.move(@current_piece, 3, 0)
      @board.move(@opponent, 4, 0)
      @board.move(@current_piece, 4, 0)
      expect(game.pawn_impossible(@current_piece, 4, 0))
      expect(@board.space_open?(4, 0)).to eql false
    end
  end

  context "saving and loading the game" do
    it "saves the game" do
      Dir.chdir("save")
      File.open("save.txt", 'w') { |file| file.write(YAML::dump(self))}
      expect(File.exist?("save.txt")).to eql true
      Dir.chdir("..")
    end

    it "loads the game" do
      Dir.chdir("save")
      expect(File.exist?("save.txt")).to eql true
      expect(YAML::load(File.read("save.txt")))
      Dir.chdir("..")
    end
  end

  context "game over" do
    it "asks the player to play another game" do
      allow(game).to receive(:gets).and_return('y')
      expect(game.play_again?).to be true
      allow(game).to receive(:gets).and_return('n', '4', '/n')
      expect(game.play_again?).to be false
    end
  end

  describe "Player" do

    context "#initialize" do
      it "initializes player objects" do
        expect(game.player1).to be_an_instance_of Player
        expect(game.player2).to be_an_instance_of Player
      end

      it "initializes player name and color" do
        expect(game.player1.color).to eql "White"
        expect(game.player2.color).to eql "Black"
      end
    end
  end

  describe "Board" do

    before :each do
      @board = Board.new
    end

    context "#initialize" do
      it "initializes the board object" do
        expect(@board).to be_an_instance_of Board
      end

      it "displays the game board" do
        expect(@board).to be_truthy
        expect(@board.display_board).to eql @board.create_board
      end
    end

    context "checking board conditions" do
      it "only allows player to select own piece" do
        @current_piece = Pawn.new("white", ("\u265F"), 1, 0)
        @current_player = Player.new("White")
        expect(@board.check_color?(@current_piece.color, @current_player.color)).to eql true
        @current_player = Player.new("Black")
        expect(@board.check_color?(@current_piece.color, @current_player.color)).to eql false
      end

      it "checks if space is an empty square" do
        @current_piece = Pawn.new("white", ("\u265F"), 1, 0)
        expect(@board.space_open?(@current_piece.column, @current_piece.row)).to eql false
        expect(@board.space_open?(4, 5)).to eql true
      end
    end

    context "updating board conditions" do
      it "moves a piece" do
        @current_piece = Pawn.new("white", ("\u265F"), 1, 0)
        @board.move(@current_piece, 2, 0)
        expect(@board.check(2, 0)).to eql @current_piece
      end

      it "updates the piece's location parameters" do
        @current_piece = Pawn.new("white", ("\u265F"), 1, 0)
        @board.move(@current_piece, 2, 0)
        expect(@current_piece.column).to eql 2
        expect(@current_piece.row).to eql 0
      end

      it "empties the space previously occupied by a piece and moves the piece" do
        @current_piece = Pawn.new("white", ("\u265F"), 1, 0)
        @board.move(@current_piece, 2, 0)
        @board.empty_space(1, 0)
        expect(@board.space_open?(1, 0)).to eql true
        expect(@board.space_open?(2, 0)).to eql false
      end
    end
  end

  describe "Piece" do

    context "#initialize" do
      it "initializes the piece object" do
        @current_piece = Piece.new("white", nil, nil, nil)
        expect(@current_piece).to be_an_instance_of Piece
      end
    end
  end

  describe "Pawn" do
    context "#initialize" do
      it "initializes the pawn object" do
        @current_piece = Pawn.new("white", ("\u265F"), 1, 0)
        expect(@current_piece).to be_an_instance_of Pawn
        expect(@current_piece.color).to eql "white"
        expect(@current_piece.column).to eql 1
        expect(@current_piece.row).to eql 0
      end
    end

    context "#move_possible?" do
      it "returns true if move is valid and false if invalid." do
        @current_piece = Pawn.new("white", ("\u265F"), 1, 0)
        expect(@current_piece.move_possible?(@current_piece, 2, 0)).to eql true
        expect(@current_piece.move_possible?(@current_piece, 3, 0)).to eql false
        expect(@current_piece.move_possible?(@current_piece, 0, 0)).to eql false
        expect(@current_piece.move_possible?(@current_piece, 2, 1)).to eql false
        expect(@current_piece.move_possible?(@current_piece, 5, 4)).to eql false
      end
    end
  end

  describe "Rook" do
    context "#initialize" do
      it "initializes the rook object" do
        @current_piece = Rook.new("white", ("\u265C"), 0, 0)
        expect(@current_piece).to be_an_instance_of Rook
      end
    end

    context "#move_possible?" do
      it "returns true if move is valid and false if invalid." do
        @current_piece = Rook.new("white", ("\u265C"), 4, 4)
        expect(@current_piece.move_possible?(@current_piece, 4, 0)).to eql true
        expect(@current_piece.move_possible?(@current_piece, 4, 6)).to eql true
        expect(@current_piece.move_possible?(@current_piece, 2, 4)).to eql true
        expect(@current_piece.move_possible?(@current_piece, 0, 0)).to eql false
        expect(@current_piece.move_possible?(@current_piece, 2, 1)).to eql false
        expect(@current_piece.move_possible?(@current_piece, 5, 5)).to eql false
      end
    end
  end

  describe "Knight" do
    context "#initialize" do
      it "initializes the knight object" do
        @current_piece = Knight.new("white", ("\u265E"), 0, 1)
        expect(@current_piece).to be_an_instance_of Knight
      end
    end

    context "#move_possible?" do
      it "returns true if move is valid and false if invalid." do
        @current_piece = Knight.new("white", ("\u265E"), 6, 3)
        expect(@current_piece.move_possible?(@current_piece, 4, 2)).to eql true
        expect(@current_piece.move_possible?(@current_piece, 4, 4)).to eql true
        expect(@current_piece.move_possible?(@current_piece, 5, 5)).to eql true
        expect(@current_piece.move_possible?(@current_piece, 7, 0)).to eql false
        expect(@current_piece.move_possible?(@current_piece, 2, 1)).to eql false
        expect(@current_piece.move_possible?(@current_piece, 6, 4)).to eql false
      end
    end
  end

  describe "Bishop" do
    context "#initialize" do
      it "initializes the bishop object" do
        @current_piece = Bishop.new("white", ("\u265D"), 0, 2)
        expect(@current_piece).to be_an_instance_of Bishop
      end
    end

    context "#move_possible?" do
      it "returns true if move is valid and false if invalid." do
        @current_piece = Bishop.new("white", ("\u265E"), 6, 3)
        expect(@current_piece.move_possible?(@current_piece, 5, 2)).to eql true
        expect(@current_piece.move_possible?(@current_piece, 3, 0)).to eql true
        expect(@current_piece.move_possible?(@current_piece, 7, 2)).to eql true
        expect(@current_piece.move_possible?(@current_piece, 7, 0)).to eql false
        expect(@current_piece.move_possible?(@current_piece, 2, 1)).to eql false
        expect(@current_piece.move_possible?(@current_piece, 6, 6)).to eql false
      end
    end
  end

  describe "Queen" do
    context "#initialize" do
      it "initializes the queen object" do
        @current_piece = Queen.new("white", ("\u265A"), 0, 4)
        expect(@current_piece).to be_an_instance_of Queen
      end
    end

    context "#move_possible?" do
      it "returns true if move is valid and false if invalid." do
        @current_piece = Queen.new("white", ("\u265E"), 6, 3)
        expect(@current_piece.move_possible?(@current_piece, 5, 2)).to eql true
        expect(@current_piece.move_possible?(@current_piece, 3, 0)).to eql true
        expect(@current_piece.move_possible?(@current_piece, 7, 2)).to eql true
        expect(@current_piece.move_possible?(@current_piece, 6, 0)).to eql true
        expect(@current_piece.move_possible?(@current_piece, 2, 3)).to eql true
        expect(@current_piece.move_possible?(@current_piece, 7, 0)).to eql false
        expect(@current_piece.move_possible?(@current_piece, 2, 1)).to eql false
        expect(@current_piece.move_possible?(@current_piece, 5, 6)).to eql false
      end
    end
  end

  describe "King" do
    context "#initialize" do
      it "initializes the king object" do
        @current_piece = King.new("white", ("\u265F"), 1, 0)
        expect(@current_piece).to be_an_instance_of King
      end
    end

    context "#move_possible?" do
      it "returns true if move is valid and false if invalid." do
        @current_piece = King.new("white", ("\u265E"), 6, 3)
        expect(@current_piece.move_possible?(@current_piece, 6, 2)).to eql true
        expect(@current_piece.move_possible?(@current_piece, 5, 2)).to eql true
        expect(@current_piece.move_possible?(@current_piece, 6, 2)).to eql true
        expect(@current_piece.move_possible?(@current_piece, 5, 4)).to eql true
        expect(@current_piece.move_possible?(@current_piece, 6, 5)).to eql false
        expect(@current_piece.move_possible?(@current_piece, 2, 3)).to eql false
        expect(@current_piece.move_possible?(@current_piece, 5, 6)).to eql false
      end
    end
  end
end