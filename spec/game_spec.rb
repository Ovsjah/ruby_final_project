require 'game'

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
      piece = Pieces::Rook.new(:black, 0)
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
      piece_black_e = nil
      
      [@player_white, @player_black].each do |player|
      
        if player.color == :white
          piece = @player_white.get(:e2, pos = :e4)
        else
          piece = @player_black.get(:e7, pos = :e5)
          piece_black_e = piece
        end
        
        @game.pick(piece)
        player.move(piece, pos)
        @game.place(piece)
        piece.update_moves
      end
      
      @board.visualize
      
      expect(@game.adjust_pawn_possible_moves(piece_black_e)).to eq([:e4])
    end
  end
  
  describe '#adjust_pawn_taking' do
    it "adds taking targets to pawn's possible_moves" do
      piece_white_d = nil
      piece_black_e = nil
      
      [@player_white, @player_black].each do |player|
      
        if player.color == :white
          piece = @player_white.get(:d2, pos = :d4)
          piece_white_d = piece
        else
          piece = @player_black.get(:e7, pos = :e5)
          piece_black_e = piece
        end
        
        @game.pick(piece)
        player.move(piece, pos)
        @game.place(piece)
        piece.update_moves
        @game.adjust_pawn_taking(piece_white_d)
        
      end
      
      @game.adjust_pawn_taking(piece_black_e)
      
      @board.visualize
      
      expect(piece_white_d.possible_moves).to eq([:d5, :e5])
      expect(piece_black_e.possible_moves).to eq([:e4, :d4])
    end
  end
  
  describe '#adjust_pawn_taking_en_passant' do
    it "adds passant to pawn's possible_moves" do
      piece_white_e = nil
     
      2.times do |i|
        [@player_white, @player_black].each do |player|
            
          if i == 0 && player.color == :white
            piece = @player_white.get(:e2, pos = :e4)
          elsif i == 0 && player.color == :black
            piece = @player_black.get(:a7, pos = :a5)
          elsif i == 1 && player.color == :white
            piece = @player_white.get(:e4, pos = :e5)
            piece_white_e = piece
          elsif i == 1 && player.color == :black
            piece = @player_black.get(:f7, pos = :f5)
          end
            
          @game.pick(piece)
          player.move(piece, pos)
          @game.place(piece)
          piece.update_moves
          @game.adjust_pawn_taking_en_passant(piece_white_e) unless piece_white_e.nil?
        end
      end
        
      @board.visualize
        
      expect(piece_white_e.possible_moves).to eq([:e6, :f6])
    end
  end
  
  describe '#adjust_knight_possible_moves' do
    it "returns an adjusted array of knight's possible moves" do
      knights = [
        knight_white_b = @player_white.pieces[:knight_b1],
        knight_white_g = @player_white.pieces[:knight_g1],
        knight_black_b = @player_black.pieces[:knight_b8],
        knight_black_g = @player_black.pieces[:knight_g8]
      ]
      
      knights.each { |knight| @game.adjust_knight_possible_moves(knight) }
      
      expect(knight_white_b.possible_moves).to eq([:a3, :c3])
      expect(knight_white_g.possible_moves).to eq([:f3, :h3])
      expect(knight_black_b.possible_moves).to eq([:a6, :c6])
      expect(knight_black_g.possible_moves).to eq([:f6, :h6])
    end
  end
  
  describe '#adjust_possible_moves' do
    it "returns an adjusted array of piece's (except pawn and knight) possible moves" do
      
      kings = [
        king_white = @player_white.pieces[:king_e1],
        king_black = @player_black.pieces[:king_e8]
      ]
      
      queens = [
        queen_white = @player_white.pieces[:queen_d1],
        queen_black = @player_black.pieces[:queen_d8]
      ]
      
      bishops = [
        bishop_white_c = @player_white.pieces[:bishop_c1],
        bishop_white_f = @player_white.pieces[:bishop_f1],
        bishop_black_c = @player_black.pieces[:bishop_c8],
        bishop_black_f = @player_black.pieces[:bishop_f8]
      ]
      
      rooks = [
        rook_white_a = @player_white.pieces[:rook_a1],
        rook_white_h = @player_white.pieces[:rook_h1],
        rook_black_a = @player_black.pieces[:rook_a8],
        rook_black_h = @player_black.pieces[:rook_h8]
      ]
      
      pieces = [kings, queens, bishops, rooks]
      
      pieces.each do |pairs|
        pairs.each do |piece|
          @game.adjust_possible_moves(piece)
        end
      end
      
      pieces.each do |pairs|
        pairs.each do |piece|
          expect(piece.possible_moves).to eq([])
        end
      end
      
      2.times do |i|
        [@player_white, @player_black].each do |player|
          if player.color == :white
            queen = queens[0]
          else
            queen = queens[1]
          end
          
          piece =
            case
            when i == 0 && player.color == :white 
              player.get(:e2, pos = :e4)            
            when i == 0 && player.color == :black
              player.get(:e7, pos = :e5)
            when i == 1 && player.color == :white
              player.get(:d1, pos = :h5)
            when i == 1 && player.color == :black
              piece = player.get(:d8, pos = :g5)
            end
          
          @game.pick(piece)
          player.move(piece, pos)
          @game.place(piece)
          
          piece.update_moves
          queen.update_moves
          
          @game.adjust_possible_moves(queen)
        end
      end
      
      @game.adjust_possible_moves(queen_white)
      @game.adjust_possible_moves(queen_black)
      
      expect(queen_white.possible_moves).to eq([:d1, :e2, :f7, :f3, :g6, :g5, :g4, :h7, :h6, :h4, :h3])
      expect(queen_black.possible_moves).to eq([:d8, :d2, :e7, :e3, :f6, :f5, :f4, :g6, :g4, :g3, :g2, :h6, :h5, :h4]
)
      @board.visualize
    end
  end
  
  describe '#check?' do
    it "returns true of false if check" do
      queen_white = @player_white.pieces[:queen_d1]
      
      2.times do |i|
        [@player_white, @player_black].each do |player|
                 
          piece =
            case
            when i == 0 && player.color == :white 
              player.get(:e2, pos = :e4)            
            when i == 0 && player.color == :black
              player.get(:f7, pos = :f5)
            when i == 1 && player.color == :white
              player.get(:d1, pos = :h5)
            when i == 1 && player.color == :black
              player.get(:g7, pos = :g6)
            end
            
          @game.pick(piece)
          player.move(piece, pos)
          @game.place(piece)
          
          @game.update_moves(player)        
        end
      end
      
      @board.visualize 
      @game.update_moves(@player_white)
      
      expect(@game.check?(queen_white)).to eq(false)         
    end
  end
  
  describe '#stalemate?' do
    it "returns true or false when stalemate" do
    
      king_black = @player_black.pieces[:king_e8]
      king_white = @player_white.pieces[:king_e1]
      
      10.times do |i|
        [@player_white, @player_black].each do |player|
          @game.update_moves(player)       
          piece =
            case
            when i == 0 && player.color == :white 
              player.get(:e2, pos = :e3)            
            when i == 0 && player.color == :black
              player.get(:a7, pos = :a5)
            when i == 1 && player.color == :white
              player.get(:d1, pos = :h5)
            when i == 1 && player.color == :black
              player.get(:a8, pos = :a6)
            when i == 2 && player.color == :white
              player.get(:h5, pos = :a5)
            when i == 2 && player.color == :black
              player.get(:h7, pos = :h5)
            when i == 3 && player.color == :white
              player.get(:h2, pos = :h4)
            when i == 3 && player.color == :black
              player.get(:a6, pos = :h6)
            when i == 4 && player.color == :white
              player.get(:a5, pos = :c7)
            when i == 4 && player.color == :black
              player.get(:f7, pos = :f6)            
            when i == 5 && player.color == :white
              player.get(:c7, pos = :d7)
            when i == 5 && player.color == :black
              player.get(:e8, pos = :f7)
            when i == 6 && player.color == :white
              player.get(:d7, pos = :b7)
            when i == 6 && player.color == :black
              player.get(:d8, pos = :d3)
            when i == 7 && player.color == :white
              player.get(:b7, pos = :b8)
            when i == 7 && player.color == :black
              player.get(:d3, pos = :h7)
            when i == 8 && player.color == :white
              player.get(:b8, pos = :c8)
            when i == 8 && player.color == :black
              player.get(:f7, pos = :g6)
            when i == 9 && player.color == :white
              player.get(:c8, pos = :e6)
            when i == 9 && player.color == :black
              break
            end
                                                           
          @game.pick(piece)
          player.move(piece, pos)
          @game.place(piece)
          
          @game.update_moves(player)
          enemy_king = player.color == :white ? king_black : king_white
          @game.remove_from_board(player, enemy_king)        
        end
      end

      expect(@game.stalemate?(@player_black)).to eq(true)
      
      @board.visualize 
    end
  end
end
