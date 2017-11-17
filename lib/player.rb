class Player
  
  PIECES = [
    :pawn, :king,
    :queen, :bishop,
    :knight, :rook
  ]
  
  attr_accessor :name, :color, :pieces
  
  def initialize(name, color=:white)
    @name = name
    @color = color
    @pieces = {}
     
    PIECES.each do |piece|
      8.times do |i|

        object = Factory.create(piece, {:color => color, :type => i})
        @pieces["#{piece}_#{object.position}".to_sym] = object
        
        if [:king, :queen].include? piece
          break
        elsif [:bishop, :knight, :rook].include? piece
          break if i == 1
        end
        
      end

    end
  end
  
  def get(start, finish)
    pieces.detect { |_key, piece| (piece.position == start) && (piece.possible_moves.include? finish) }[1]
  end
  
  def move(piece, finish)
    piece.position = finish    
    piece
  end    
end
