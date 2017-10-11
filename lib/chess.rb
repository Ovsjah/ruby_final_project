class Board
  attr_accessor :grid
  
  def initialize
    @grid = Array.new(8) do
      Array.new(8) { "   " }
    end
  end
  
  def hash_map
    res = {}
    alph = ('a'..'h').to_a
    
    grid.each_with_index do |row, row_index|
      row.each_with_index do |cell, cell_index|
        res["#{alph[cell_index]}#{row_index+1}".to_sym] = {[row_index, cell_index] => cell}
      end
    end
    
    res
  end
  
  def colorize(text, color_code)
    "\e[#{color_code}m#{text}\e[0m"
  end        
  
  def visualize
    puts %q{
------------------------------   
|   a  b  c  d  e  f  g  h   |}
    
    7.downto(0) do |i|
        print "|#{i+1} "
        
      grid[i].each_with_index do |cell, cell_idx|

        if i.even? && cell_idx.even?
          print colorize(cell, "30;46")
        elsif i.odd? && cell_idx.odd?
          print colorize(cell, "30;46")
        else
          print colorize(cell, "30;47")
        end
        
      end
      
      puts " #{i+1}|"
    end
    
    puts %q{|   a  b  c  d  e  f  g  h   |
------------------------------}    
  end
end


class Pawn

  CHARS = {
    :white => [:a2, :b2, :c2, :d2, :e2, :f2, :g2, :h2, "\u2659"],
    :black => [:a7, :b7, :c7, :d7, :e7, :f7, :g7, :h7, "\u265F"]
  }
        
  attr_accessor :char, :position, :possible_moves
  
  def initialize(color, type) 
    @position = self.class::CHARS[color][type]      
    @char = self.class::CHARS[color][-1]
    @possible_moves = []
  end
end



class King < Pawn
  CHARS = {:white => [:e1, "\u2654"], :black => [:e8, "\u265A"]}
end


class Queen < Pawn
  CHARS = {:white => [:d1, "\u2655"], :black => [:d8, "\u265B"]}
end


class Bishop < Pawn
  CHARS = {:white => [:c1, :f1, "\u2657"], :black => [:f8, :c8, "\u265D"]}
end


class Knight < Pawn
  CHARS = {:white => [:g1, :b1, "\u2658"], :black => [:b8, :g8, "\u265E"]}
end


class Rook < Pawn
  CHARS = {:white => [:a1, :h1, "\u2656"], :black => [:h8, :a8, "\u265C"]}
end


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
  
  def place(piece, board)
    coord = board.hash_map[piece.position].keys[0]
    board.grid[coord[0]][coord[1]][1] = piece.char
  end  
end


class Game

  attr_accessor :player_white, :player_black, :board
  
  def initialize
    @board = Factory.create(:board)
    @player_white = Factory.create(:player, {:name => 'Ovsjah', :color => :white})
    @player_black = Factory.create(:player, {:name => 'Weasel', :color => :black})
  end
  
  def setup
    [player_white, player_black].each do |player|
      player.pieces.each do |key, piece|
        player.place(piece, board)
      end
    end
  end
end
    
    
module Factory
  
  COMPONENTS = {
    :board => Board,
    :player => Player
  }
  
  PIECES = {
    :pawn => Pawn,
    :king => King,
    :queen => Queen,
    :bishop => Bishop,
    :knight => Knight,
    :rook => Rook,
  }
  
  def self.create(component, options={})
    
    if component == :board
      COMPONENTS[component].new    
    elsif component == :player
      COMPONENTS[component].new(options[:name], options[:color])
    else
      PIECES[component].new(options[:color], options[:type])
    end
    
  end
end  


  
#ovsjah = Player.new('Ovsjah', :white)
#weasel = Player.new('Weasel', :black)
#game = Game.new

#game.setup
#game.board.visualize
#p game
#p ovsjah
#p weasel
