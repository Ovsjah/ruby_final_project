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
    :black => [:a7, :b7, :c7, :d7, :e7, :f7, :g7, :h7, "\u265f"]
  }
        
  attr_accessor :char, :position, :prev_position, :passant, :possible_moves
  
  def initialize(color, type)
    @char = self.class::CHARS[color][-1]
    @position = self.class::CHARS[color][type]      
    @prev_position = nil
    @passant = []
    @possible_moves = update_moves 
  end
  
  def update_moves
    a = position[0]
    b = position[1].to_i
    
    @possible_moves = 
     case
      when char == '♟' && b == 7
        ["#{a}#{b - 1}".to_sym, "#{a}#{b - 2}".to_sym]
      when char == '♙' && b == 2
        ["#{a}#{(b + 1)}".to_sym, "#{a}#{(b + 2)}".to_sym]
      when char == '♟'
        ["#{a}#{b - 1}".to_sym]
      when char == '♙'
        ["#{a}#{(b + 1)}".to_sym]
      end
    
  end
  
  def taking
    a = position[0]
    b = position[1].to_i
    prev = (a.ord - 1).chr       
    
    targets = 
      case
      when char == '♟' && a == 'a'
        ["#{a.next}#{b - 1}".to_sym]
      when char == '♟' && a == 'h'
        ["#{prev}#{b - 1}".to_sym]
      when char == '♙' && a == 'a'
        ["#{a.next}#{b + 1}".to_sym]
      when char == '♙' && a == 'h'
        ["#{prev}#{b + 1}".to_sym]
      when char == '♟'
        ["#{prev}#{b - 1}".to_sym, "#{a.next}#{b - 1}".to_sym]
      when char == '♙'
        ["#{prev}#{b + 1}".to_sym, "#{a.next}#{b + 1}".to_sym]
      end
      
  end
  
  def taking_en_passant
    a = position[0]
    b = position[1].to_i
    prev = (a.ord - 1).chr
    
    cells_to_check =
      case
      when char == '♙' && a == 'a' && b == 5
        ["#{a.next}#{b + 2}".to_sym]
      when char == '♙' && a == 'h' && b == 5
        ["#{prev}#{b + 2}".to_sym]
      when char == '♟' && a == 'a' && b == 4
        ["#{a.next}#{b - 2}".to_sym]
      when char == '♟' && a == 'h' && b == 4
        ["#{prev}#{b - 2}".to_sym]
      when char == '♙' && b == 5
        ["#{prev}#{b + 2}".to_sym, "#{a.next}#{b + 2}".to_sym]
      when char == '♟' && b == 4
        ["#{prev}#{b - 2}".to_sym, "#{a.next}#{b - 2}".to_sym]
      end

  end
  
  def promote
  
    pieces = [
      'queen', 'rook',
      'knight', 'bishop'
    ]
    
    b = position[1]
    
    pieces if char == '♙' && b == '8' || char == '♟' && b == '1'
    
  end
  
end


class King < Pawn
  CHARS = {:white => [:e1, "\u2654"], :black => [:e8, "\u265a"]}
end


class Queen < Pawn
  CHARS = {:white => [:d1, "\u2655"], :black => [:d8, "\u265b"]}
end


class Bishop < Pawn
  CHARS = {:white => [:c1, :f1, "\u2657"], :black => [:f8, :c8, "\u265d"]}
end


class Knight < Pawn
  CHARS = {:white => [:g1, :b1, "\u2658"], :black => [:b8, :g8, "\u265e"]}
end


class Rook < Pawn
  CHARS = {:white => [:a1, :h1, "\u2656"], :black => [:h8, :a8, "\u265c"]}
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
  
  def get(start, finish)
    pieces.detect { |_key, piece| (piece.position == start) && (piece.possible_moves.include? finish) }[1]
  end
  
  def move(piece, finish)
    piece.prev_position = piece.position
    piece.position = finish
    
    piece
  end
    
end


class Game
  
  @@position_to_remove = nil
  
  attr_accessor :player_white, :player_black, :board

  def self.position_to_remove
    @@position_to_remove
  end
  
  def self.position_to_remove=(position)
    @@position_to_remove = position
  end
  
  def initialize
    @board = Factory.create(:board)
    @player_white = Factory.create(:player, {:name => 'Ovsjah', :color => :white})
    @player_black = Factory.create(:player, {:name => 'Weasel', :color => :black})
  end
  
  def setup
    [player_white, player_black].each do |player|
      player.pieces.each do |key, piece|
        place(piece)
      end
    end
  end
  
  def play
    setup
    
    loop do
      
      [player_white, player_black].each do |player|

        update_moves(player)

        board.visualize
        
        puts "#{player.color} turn"
        
        print '>> '
        
        move = gets.split(/\s/)
        
        start, finish = move[0].to_sym, move[1].to_sym
        
        piece = player.get(start, finish)
        
        pick(piece)
        
        piece = player.move(piece, finish)
        
        place(piece)
        
        if piece.promote
          piece = pawn_promote(player, piece) 
          add(player, piece)
        end
        
        pick(piece.passant) unless piece.passant.is_a? Array
        
        remove_passant(player)
        
        update_moves(player)
       
      end
    end
  end 
  
  #private
  
  def pick(piece)
    coord = board.hash_map[piece.position].keys[0]
    board.grid[coord[0]][coord[1]][1] = ' '    
  end
  
  def place(piece)
    coord = board.hash_map[piece.position].keys[0]
    board.grid[coord[0]][coord[1]][1] = piece.char
  end
  
  def add(player, piece)
    name = piece.class.to_s.downcase.to_sym
    player.pieces["#{name}_#{piece.position}".to_sym] = piece
  end
  
  def remove(player, piece, key = nil)
  
    if key.nil?
      key = player.pieces.detect { |key, value| value.position == piece.position }[0]
    end
    
    coord = board.hash_map[piece.position].keys[0]
    p "key to be deleted => #{key}" if board.grid[coord[0]][coord[1]][1] != piece.char
    player.pieces.delete(key) if board.grid[coord[0]][coord[1]][1] != piece.char
  end
  
  
  def update_moves(player)
    player.pieces.each do |key, piece|
    
      remove(player, piece, key)
      
      piece.update_moves if piece.is_a? Pawn
      
      adjust(piece, player.color) if piece.is_a? Pawn
      
    end
  end
  
  def adjust(piece, color)

    adjust_pawn_possible_moves(piece) if piece.class == Pawn
    
    adjust_pawn_taking(piece, color) if piece.class == Pawn 

    adjust_pawn_taking_en_passant(piece, color) if piece.taking_en_passant

  end
  
  def pawn_promote(player, piece)
    
    puts "Choose the piece to promote the pawn to.\n #{piece.promote}"
      
    print '>> '
    
    choice = gets.chomp.to_sym
    
    new_piece = Factory.create(choice, {:color => player.color, :type => 0})
    
    new_piece.position = piece.position
    
    place(new_piece)
   
    remove(player, piece)
    
    new_piece
    
  end
  
  def adjust_pawn_possible_moves(piece)
    piece.possible_moves.delete_if { |move| p move; board.hash_map[move].values[0] != "   " }
  end
  
  def adjust_pawn_taking(piece, color)
    piece.taking.each do |target|     
      piece.possible_moves << target if (black?(target) && color == :white) || (white?(target) && color == :black)            
    end
  end
  
  def adjust_pawn_taking_en_passant(piece, color)
  
    if piece.taking_en_passant && !piece.passant.empty?
    
      piece.passant = piece.passant.detect { |passant| piece.position[1] == passant.position[1] }
      
      if piece.passant
      
        if ("a".."#{piece.position[0]}").include? piece.passant.position[0]
          piece.possible_moves << piece.taking[0]
        elsif ("#{piece.position[0]}".."h").include? piece.passant.position[0]
          piece.possible_moves << piece.taking[-1]
        end
        
      else
        piece.passant = []
      end
    end    
    
    if piece.taking_en_passant && (piece.passant.is_a? Array)
      piece.taking_en_passant.each do |target|
        piece.passant << enemy(target, color) if black?(target) || white?(target)
      end
    end
  end
  
  def white?(target)
    (4..9).include? board.hash_map[target].values[0][1].ord.to_s(16)[3].to_i
  end
  
  def black?(target)
    ('a'..'f').include? board.hash_map[target].values[0][1].ord.to_s(16)[3]
  end
  
  def enemy(target, color)
    player = (color == :white) ? player_black : player_white
    player.pieces.detect { |_key, piece| piece.position == target }[1]
  end
  
  def remove_passant(player)
    player.pieces.each { |_key, piece| piece.passant = [] }
  end
end
    
    
module Factory
  
  COMPONENTS = {
    :board => Board,
    :player => Player,
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
      COMPONENTS[component].new(options[:color], options[:type])
    end
    
  end
end  



#game = Game.new

#game.play
