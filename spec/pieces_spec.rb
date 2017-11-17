require 'pieces'

describe Pieces::King do

  before(:all) do
    @king_white = Pieces::King.new(:white, 0)
    @king_black = Pieces::King.new(:black, 0)
  end
  
  describe '#new' do
    it "returns a king object" do
      expect(@king_white).to be_an_instance_of(Pieces::King)
    end
  end
  
  describe '#char' do
    it "returns '♔'" do
      expect(@king_white.char).to eq('♔')
    end
  end
  
  describe '#position' do
    it "returns the position of the king" do
      expect(@king_white.position).to eq(:e1)
    end
  end
  
  describe '#possible_moves' do
    it "returns possible_moves" do
      expect(@king_white.possible_moves).to eq([:d2, :d1, :e2, :f2, :f1])
      expect(@king_black.possible_moves).to eq([:d8, :d7, :e7, :f8, :f7])
    end
  end
end


describe Pieces::Queen do

  before(:all) do
    @queen = Pieces::Queen.new(:black, 0)
  end
  
  describe '#new' do
    it "returns a queen object" do
      expect(@queen).to be_an_instance_of(Pieces::Queen)
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


describe Pieces::Bishop do

  before(:all) do
    @bishop = Pieces::Bishop.new(:white, 0)
  end
  
  describe '#new' do
    it "returns a bishop object" do
      expect(@bishop).to be_an_instance_of(Pieces::Bishop)
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
  
  #describe '#alts' do
    #it "returns altitudes" do
      #expect(@bishop.alts).to eq([])
    #end
  #end
end


describe Pieces::Knight do

  before(:all) do
    [:white, :black].each do |color|
      {'b' => 0, 'g' => 1}.each do |key, value|
        eval "\@knight_#{color}_#{key} = Pieces::Knight.new(color, value)"
      end
    end
  end
  
  describe '#new' do
    it "returns a knight object" do
      expect(@knight_black_g).to be_an_instance_of(Pieces::Knight)
    end
  end
  
  describe '#char' do
    it "returns '♞'" do
      expect(@knight_black_g.char).to eq('♞')
    end
  end
  
  describe '#position' do
    it "returns knight's position" do
      expect(@knight_black_g.position).to eq(:g8)
    end
  end
  
  describe '#possible_moves' do
    it "returns possible_moves" do
      expect(@knight_black_g.possible_moves).to eq([:e7, :f6, :h6])
      expect(@knight_black_b.possible_moves).to eq([:a6, :c6, :d7])
      expect(@knight_white_b.possible_moves).to eq([:a3, :c3, :d2])
      expect(@knight_white_g.possible_moves).to eq([:e2, :f3, :h3])
    end
  end
end


describe Pieces::Rook do

  before(:all) do
    @rook = Pieces::Rook.new(:white, 0)
  end
  
  describe '#new' do
    it "returns a rook object" do
      expect(@rook).to be_an_instance_of(Pieces::Rook)
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


describe Pieces::Pawn do
  
  before(:all) do
    [:white, :black].each do |color|
      {'a' => 0, 'e' => 4, 'h' => 7}.each do |key, value|
        eval "\@pawn_#{color}_#{key} = Pieces::Pawn.new(color, value)"
      end
    end
  end
  
  describe '#new' do
    it "returns a pawn object" do
      expect(@pawn_black_e).to be_an_instance_of(Pieces::Pawn)
    end
  end
  
  describe '#color' do
    it "returns pawn's color" do
      expect(@pawn_black_e.color).to eq(:black)
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
