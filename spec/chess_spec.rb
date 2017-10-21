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
    @pawn_black = Pawn.new(:black, 4)
    @pawn_white = Pawn.new(:white, 4) 
  end
  
  describe '#new' do
    it "returns a pawn object" do
      expect(@pawn_black).to be_an_instance_of(Pawn)
    end
  end
  
  describe '#char' do
    it "returns '♟'" do
      expect(@pawn_black.char).to eq('♟')
    end
  end
    
  describe '#position' do
    it "returns pawn's position" do
      expect(@pawn_black.position).to eq(:e7)
    end
  end
  
  describe '#taking' do
    it "returns targets to be taken" do
      expect(@pawn_black.taking).to eq([:d6, :f6])
      expect(@pawn_white.taking).to eq([:d3, :f3])
    end
  end
  
  describe '#possible_moves' do
    it "returns possible_moves" do
      expect(@pawn_black.possible_moves).to eq([:e6, :e5])
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
  
  describe '#place' do
    it "places a chess piece on the board" do
      expect(@player_white.place(@piece, @board)).to eq('♔')
      @board.visualize
    end
  end
end


describe Game do

  before(:all) do
    @game = Game.new
    @board = @game.board
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
end
