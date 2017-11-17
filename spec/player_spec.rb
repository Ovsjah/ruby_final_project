require 'pieces'
require 'board'
require 'player'
require 'factory'

describe Player do

  before(:all) do
    @player_white = Player.new('Ovsjah', :white)
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
