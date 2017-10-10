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


class King
  attr_accessor :char, :position, :possible_moves
  
  CHARS = {:white => [:e1, "\u2654"], :black => [:e8, "\u265A"]}
  
  def initialize(color)
    @position = self.class::CHARS[color][0]
    @char = self.class::CHARS[color][1]
    @possible_moves = []
  end
end


class Queen < King
  CHARS = {:white => [:d1, "\u2655"], :black => [:d8, "\u265B"]}
end


class Bishop

  CHARS = {:white => [:c1, :f1, "\u2657"], :black => [:f8, :c8, "\u265D"]}
  
  attr_accessor :char, :position, :possible_moves
  
  def initialize(color, type=:light)
    color = color.to_sym

    if type == :dark
      @position = self.class::CHARS[color][0]
    else
      @position = self.class::CHARS[color][1]
    end
    
    @char = self.class::CHARS[color][2]
    @possible_moves = []
  end
end


class Knight < Bishop
  CHARS = {:white => [:g1, :b1, "\u2658"], :black => [:b8, :g8, "\u265E"]}
end


class Rook < Bishop
  CHARS = {:white => [:a1, :h1, "\u2656"], :black => [:h8, :a8, "\u265C"]}
end


class Pawn

  CHARS = {
    :white => [:a2, :b2, :c2, :d2, :e2, :f2, :g2, :h2, "\u2659"],
    :black => [:a7, :b7, :c7, :d7, :e7, :f7, :g7, :h7, "\u265F"]
  }
        
  attr_accessor :char, :position, :possible_moves
  
  def initialize(color, type)
  
    @position = 
      case type
      when :a
        CHARS[color][0]
      when :b
        CHARS[color][1]
      when :c
        CHARS[color][2]
      when :d
        CHARS[color][3]
      when :e
        CHARS[color][4]
      when :f
        CHARS[color][5]
      when :g
        CHARS[color][6]
      when :h
        CHARS[color][7]
      end
      
    @char = CHARS[color][8]
    @possible_moves = []
  end
end


class Player
  
  attr_accessor :name, :color, :pieces
  
  def initialize(name, color=:white)
    @name = name
    @color = color
    
    @pieces = {
      :king => King.new(color),
      :queen => Queen.new(color),
      :bishop_dark => Bishop.new(color, :dark),
      :bishop_light => Bishop.new(color),
      :knight_light => Knight.new(color),
      :knight_dark => Knight.new(color, :dark),
      :rook_light => Rook.new(color),
      :rook_dark => Rook.new(color, :dark),
      :pawn_a => Pawn.new(color, :a),
      :pawn_b => Pawn.new(color, :b),
      :pawn_c => Pawn.new(color, :c),
      :pawn_d => Pawn.new(color, :d),
      :pawn_e => Pawn.new(color, :e),
      :pawn_f => Pawn.new(color, :f),
      :pawn_g => Pawn.new(color, :g),
      :pawn_h => Pawn.new(color, :h)
    }
  end
  
  def place(piece, board)
    coord = board.hash_map[piece.position].keys[0]
    board.grid[coord[0]][coord[1]][1] = piece.char
  end  
end


class Game

  attr_accessor :player_white, :player_black, :board

  def initialize
    @board = Board.new
    @player_white = Player.new('Ovsjah', :white)
    @player_black = Player.new('Weasel', :black)
  end
  
  def setup
    [player_white, player_black].each do |player|
      player.pieces.each do |key, piece|
        player.place(piece, board)
      end
    end
    
    #board.visualize
  end
end
    
    
    

#ovsjah = Player.new('Ovsjah', :white)
#budda = Player.new('Weasel', :black)
#game = Game.new
#game.setup
#p ovsjah
#p "-----------------------------------------------------"
#p budda

#board = Board.new
#p board.hash_map
#puts board.colorize("board", 28)
#board.grid[0][0][1] = "\u2656"
#board.grid[2][2][1] = "\u2658"
#board.grid[0][2][1] = "\u2657"
#board.grid[0][3][1] = "\u2655"
#board.grid[0][4][1] = "\u2654"

#board.visualize

#board.grid[0][5][1] = "\u2657"
#board.grid[0][6][1] = "\u2658"
#board.grid[0][7][1] = "\u2656"

#board.grid[1][0][1] = "\u2659"
#board.grid[1][1][1] = "\u2659"
#board.grid[1][2][1] = "\u2659"
#board.grid[1][3][1] = "\u2659"
#board.grid[1][4][1] = "\u2659"
#board.grid[1][5][1] = "\u2659"
#board.grid[1][6][1] = "\u2659"
#board.grid[1][7][1] = "\u2659"

#board.grid[7][0][1] = "\u265c"
#board.grid[7][1][1] = "\u265e"
#board.grid[7][2][1] = "\u265d"
#board.grid[7][3][1] = "\u265b"
#board.grid[7][4][1] = "\u265a"
#board.grid[7][5][1] = "\u265d"
#board.grid[7][6][1] = "\u265e"
#board.grid[7][7][1] = "\u265c"

#board.grid[6][0][1] = "\u265f"
#board.grid[6][1][1] = "\u265f"
#board.grid[6][2][1] = "\u265f"
#board.grid[6][3][1] = "\u265f"
#board.grid[6][4][1] = "\u265f"
#board.grid[6][5][1] = "\u265f"
#board.grid[6][6][1] = "\u265f"
#board.grid[6][7][1] = "\u265f"

#board.visualize
