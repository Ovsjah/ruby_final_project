require 'chess'


describe Board do

  before(:all) do
    @board = Board.new
  end
  
  describe '#new' do
    it "returns a board object" do
      expect(@board).to be_an_instance_of(Board)
    end
  end
  
  describe '#grid' do
    it "returns array" do
      expect(@board.grid.class).to eq(Array)
    end
  
    it "has 64 cells" do
      expect(@board.grid.size * @board.grid[0].size).to eq(64)
    end
  end
  
  describe '#colorize' do
    it "colorizes cells" do
      @board.grid.each_with_index do |row, row_idx|
        row.each_with_index do |cell, cell_idx|
          if row_idx.even? && cell_idx.even?
            expect(@board.colorize(cell, 46)).to eq("\e[46m   \e[0m")
          end
        end
      end
    end 
  end
  
  describe '#hash_map' do
    it "returns values associated with chess board coordinates" do
      @board.grid[0][6][1] = '♘'
      expect(@board.hash_map[:g1]).to eq({[0, 6]=>" ♘ "}) 
    end  
  end
  
  describe '#visualize' do
    it "prints human friendly board to the console" do
      expect(@board.visualize).to eq(nil)
    end
  end
end


describe King do

  before(:all) do
    @king = King.new(:white, 0)
  end
  
  describe '#new' do
    it "returns a king object" do
      expect(@king).to be_an_instance_of(King)
    end
  end
  
  describe '#char' do
    it "returns '♔'" do
      expect(@king.char).to eq('♔')
    end
  end
  
  describe '#position' do
    it "returns the position of the king" do
      expect(@king.position).to eq(:e1)
    end
  end
end


describe Queen do

  before(:all) do
    @queen = Queen.new(:black, 0)
  end
  
  describe '#new' do
    it "returns a queen object" do
      expect(@queen).to be_an_instance_of(Queen)
    end
  end
    
  describe '#char' do
    it "returns '♛'" do
      expect(@queen.char).to eq('♛')
    end
  end
  
  describe '#position' do
    it "returns the position of the queen" do
      expect(@queen.position).to eq(:d8)
    end
  end
end


describe Bishop do

  before(:all) do
    @bishop = Bishop.new(:white, 0)
  end
  
  describe '#new' do
    it "returns a bishop object" do
      expect(@bishop).to be_an_instance_of(Bishop)
    end
  end
  
  describe '#char' do
    it "returns '♗'" do
      expect(@bishop.char).to eq('♗')
    end
  end
  
  describe '#position' do
    it "returns the bishop's position" do
      expect(@bishop.position).to eq(:c1)
    end
  end
end


describe Knight do

  before(:all) do
    @knight = Knight.new(:black, 1)
  end
  
  describe '#new' do
    it "returns a knight object" do
      expect(@knight).to be_an_instance_of(Knight)
    end
  end
  
  describe '#char' do
    it "returns '♞'" do
      expect(@knight.char).to eq('♞')
    end
  end
  
  describe '#position' do
    it "returns knight's position" do
      expect(@knight.position).to eq(:g8)
    end
  end
end


describe Rook do

  before(:all) do
    @rook = Rook.new(:white, 0)
  end
  
  describe '#new' do
    it "returns a rook object" do
      expect(@rook).to be_an_instance_of(Rook)
    end
  end
  
  describe '#char' do
    it "returns '♖'" do
      expect(@rook.char).to eq('♖')
    end
  end
  
  describe '#position' do
    it "returns rook's position" do
      expect(@rook.position).to eq(:a1)
    end
  end
end


describe Pawn do

  before(:all) do
    [:white, :black].each do |color|
      {'a' => 0, 'e' => 4, 'h' => 7}.each do |key, value|
        eval "\@pawn_#{color}_#{key} = Pawn.new(color, value)"
      end
    end
  end
  
  describe '#new' do
    it "returns a pawn object" do
      expect(@pawn_black_e).to be_an_instance_of(Pawn)
    end
  end
  
  describe '#char' do
    it "returns '♟'" do
      expect(@pawn_black_e.char).to eq('♟')
    end
  end
    
  describe '#position' do
    it "returns pawn's position" do
      expect(@pawn_black_e.position).to eq(:e7)
    end
  end
  
  describe '#possible_moves' do
    it "returns possible_moves" do
      expect(@pawn_black_e.possible_moves).to eq([:e6, :e5])
    end
  end
    
  describe '#taking' do
    it "returns targets to be taken" do
      expect(@pawn_black_e.taking).to eq([:d6, :f6])
      expect(@pawn_black_a.taking).to eq([:b6])
      expect(@pawn_black_h.taking).to eq([:g6])
      
      expect(@pawn_white_e.taking).to eq([:d3, :f3])
      expect(@pawn_white_a.taking).to eq([:b3])
      expect(@pawn_white_h.taking).to eq([:g3])
    end
  end
  
  describe '#taking_en_passant' do
    it "returns tracked targets" do
      @pawn_black_e.position = :e4
      expect(@pawn_black_e.taking_en_passant).to eq([:d2, :f2])
      @pawn_black_a.position = :a4
      expect(@pawn_black_a.taking_en_passant).to eq([:b2])
      @pawn_black_h.position = :h4
      expect(@pawn_black_h.taking_en_passant).to eq([:g2])
      
      @pawn_white_e.position = :e5
      expect(@pawn_white_e.taking_en_passant).to eq([:d7, :f7])
      @pawn_white_a.position = :a5
      expect(@pawn_white_a.taking_en_passant).to eq([:b7])
      @pawn_white_h.position = :h5
      expect(@pawn_white_h.taking_en_passant).to eq([:g7])
    end
  end
  
  describe '#promote' do
    it "returns an array of pieces to promote the pawn to" do
      @pawn_black_e.position = :e1
      expect(@pawn_black_e.promote).to eq(['queen', 'rook', 'knight', 'bishop'])
      
      @pawn_white_e.position = :e8
      expect(@pawn_white_e.promote).to eq(['queen', 'rook', 'knight', 'bishop'])
    end
  end
end

  
describe Player do

  before(:all) do
    @player_white = Player.new('Ovsjah', :white)
    @board = Board.new
    @piece = @player_white.pieces[:king_e1]
  end
  
  describe '#new' do
    it "returns a white player object" do
      expect(@player_white).to be_an_instance_of(Player)
    end
  end
  
  describe '#name' do
    it "returns a name of a player" do
      expect(@player_white.name).to eq('Ovsjah')
    end
  end
  
  describe '#color' do
    it "returns a color of chess pieces" do
      expect(@player_white.color).to eq(:white)
    end
  end
  
  describe '#pieces' do
    it "returns a hash of chess pieces" do
      expect(@player_white.pieces.class).to eq(Hash)
      expect(@player_white.pieces[:rook_a1].char).to eq('♖')
    end
  end
  
  describe '#get' do
    it "returns a chess piece" do
      expect(@player_white.get(:e2, :e4).char).to eq("♙")
    end
  end
  
  describe '#move' do
    it "moves a chess piece and returns it" do
      piece = @player_white.get(:e2, :e4)
      expect(@player_white.move(piece, :e4).position).to eq(:e4)
    end
  end
end


describe Game do

  before(:each) do
    @game = Game.new
    @game.setup
    @board = @game.board
    @player_white = @game.player_white
    @player_black = @game.player_black
    @piece = @player_black.get(:d7, :d5)
  end
  
  describe '#new' do
    it "returns a game object" do
      expect(@game).to be_an_instance_of(Game)
    end
  end
  
  describe '#player_white' do
    it "creates a white player" do
      expect(@game.player_white.color).to eq(:white)
      expect(@game.player_white.pieces[:king_e1].char).to eq('♔')
    end
  end
  
  describe '#player_black' do
    it "creates a black player" do
      expect(@game.player_black.color).to eq(:black)
      expect(@game.player_black.pieces[:king_e8].char).to eq('♚')
    end
  end
  
  describe '#setup' do
    it "sets the chess pieces on the board" do
      @game.setup
      
      expect(@board.hash_map[:d1]).to eq([0, 3]=>" ♕ ")
      expect(@board.hash_map[:d8]).to eq([7, 3] => " ♛ ")
      
      @board.visualize
    end
  end
  
  describe '#pick' do
    it "removes the piece from the chess board" do
      expect(@game.pick(@piece)).to eq(' ')
    end
  end
  
  describe '#place' do
    it "places the piece on the right cell" do
      expect(@game.place(@piece)).to eq('♟')
    end
  end
  
  describe '#remove' do
    it "removes the piece from player's pieces hash" do
      @piece.char = "♕"
      @game.remove(@player_black, @piece)
      expect(@player_black.pieces[:pawn_d7]).to eq(nil)
    end
  end
  
  describe '#add' do
    it "adds the new piece to player's pieces hash" do
      piece = Rook.new(:black, 0)
      piece.position = :e1
      @game.add(@player_black, piece)
      expect(@player_black.pieces[:rook_e1].char).to eq('♜')
    end
  end
  
  describe '#update' do
    it "updates player's moves" do
      piece = @player_black.get(:f7, :f5)
      @player_black.move(piece, :f5)
      @game.update_moves(@player_black)
      expect(piece.possible_moves).to eq([:f4])
    end
  end
  
  describe '#adjust_pawn_possible_moves' do
    it "returns an adjusted array of pawn's possible moves" do
      piece_white = @player_white.get(:e2, :e4)
      @game.pick(piece_white)
      @player_white.move(piece_white, :e4)
      @game.place(piece_white)
    
      piece_black = @player_black.get(:e7, :e5)
      @game.pick(piece_black)
      @player_black.move(piece_black, :e5)
      @game.place(piece_black)
      piece_black.update_moves
      
      @board.visualize
      
      expect(@game.adjust_pawn_possible_moves(piece_black)).to eq([])
    end
  end
  
  describe '#adjust_pawn_taking' do
    it "adjusts pawn's possible moves by adding taking targets to it" do
      piece_white = @player_white.get(:d2, :d4)
      @game.pick(piece_white)
      @player_white.move(piece_white, :d4)
      @game.place(piece_white)
      piece_white.update_moves
      
      piece_black = @player_black.get(:e7, :e5)
      @game.pick(piece_black)
      @player_black.move(piece_black, :e5)
      @game.place(piece_black)
      piece_black.update_moves
      
      @game.adjust_pawn_taking(piece_white, :white)
      @game.adjust_pawn_taking(piece_black, :black)
      
      @board.visualize 
      
      expect(piece_white.possible_moves).to eq([:d5, :e5])
      expect(piece_black.possible_moves).to eq([:e4, :d4])
      
      piece_white_f = @player_white.get(:f2, :f4)
      @game.pick(piece_white_f)
      @player_white.move(piece_white_f, :f4)
      @game.place(piece_white_f)
      
      
      piece_black.update_moves
      @game.adjust_pawn_taking(piece_black, :black)
      
      @board.visualize
      
      expect(piece_black.possible_moves).to eq([:e4, :d4, :f4])
    end
  end
end
