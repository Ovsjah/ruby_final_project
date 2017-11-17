#require './lib/player'
#require './lib/board'
#require './lib/pieces'
require './lib/factory'

class Game
  extend Factory
  include Pieces
  
  attr_accessor :player_white, :player_black, :board
  
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
        
        if piece.class == Pawn
        
          if piece.promote
            piece = pawn_promote(player, piece) 
            add(player, piece)
          end
          
          
          if piece.class == Pawn
            unless piece.passant.is_a? Array
              pick(piece.passant) if piece.position[0] == piece.passant.position[0]
            end
          end
               
          remove_passant(player)
        end
            
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
    name = piece.class.to_s.downcase
    name.delete!("pieces::") if name.include? "pieces::"
    name = "#{name}_#{piece.position}".to_sym
    player.pieces[name] = piece
  end
  
  def remove(player, piece, key = nil)
  
    if key.nil?
      key = player.pieces.detect { |key, value| value.position == piece.position }[0]
    end
    
    coord = board.hash_map[piece.position].keys[0]

    player.pieces.delete(key) if board.grid[coord[0]][coord[1]][1] != piece.char
  end
  
  
  def update_moves(player)
  
    #king = player.color == :white ? player_white.pieces[:king_e1] : player_black.pieces[:king_e8]
    #p king
    player.pieces.each do |key, piece|
      
      remove(player, piece, key)
      
      piece.update_moves
      
      adjust(piece)
      
      #if king.check && !piece.possible_moves.nil?
        #puts "Achtung! Check!"
        
        #if piece.possible_moves.include? king.checked_from[0]
          #piece.possible_moves = [king.checked_from[0]]
        #else
          #piece.possible_moves = []
        #end
        
      #end
      
      #unless piece.possible_moves.nil?
        #check?(piece)
      #end
    end
  end
  
  def adjust(piece)
    
    if piece.class == Pawn
      adjust_pawn_possible_moves(piece)
      adjust_pawn_taking(piece)
      adjust_pawn_taking_en_passant(piece) if piece.taking_en_passant
    elsif piece.class == Knight
      adjust_knight_possible_moves(piece)
    else
      adjust_possible_moves(piece)
    end
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
    piece.possible_moves.delete_if { |move| board.hash_map[move].values[0] != "   " }
  end
  
  def adjust_pawn_taking(piece)
    piece.taking.each do |target|     
      piece.possible_moves << target if cell_with_foe?(piece, target)
    end
  end
  
  def adjust_pawn_taking_en_passant(piece)
  
    if piece.taking_en_passant && !piece.passant.empty?
    
      piece.passant = piece.passant.detect { |passant| piece.position[1] == passant.position[1] }

      if piece.passant
      
        if at_left?(piece.position, piece.passant.position)
          piece.possible_moves << piece.taking[0]
        elsif at_right?(piece.position, piece.passant.position)
          piece.possible_moves << piece.taking[-1]
        end
        
      else
        piece.passant = []
      end
    end    
    
    if piece.taking_en_passant && (piece.passant.is_a? Array)
      piece.taking_en_passant.each do |target|
        piece.passant << enemy(target, piece.color) if cell_with_foe?(piece, target) 
      end
    end
  end
  
  def adjust_knight_possible_moves(piece)
    piece.possible_moves.delete_if do |move| 
      cell_with_friend?(piece, move)
    end
  end
  
  def adjust_possible_moves(piece)
  
    lines = {
      :up_left_diagonal => [],
      :down_left_diagonal => [],
      :up_right_diagonal => [],
      :down_right_diagonal => [],
      :up => [],
      :down => [],
      :left => [],
      :right => []
    }
    
    found = []
    
    piece.possible_moves.each do |move|
      if cell_with_friend?(piece, move) || cell_with_foe?(piece, move)
        case
        when up_left_diagonal?(piece.position, move)
          lines[:up_left_diagonal] << move
        when down_left_diagonal?(piece.position, move)
          lines[:down_left_diagonal] << move
        when up_right_diagonal?(piece.position, move)
          lines[:up_right_diagonal] << move
        when down_right_diagonal?(piece.position, move)
          lines[:down_right_diagonal] << move
        when up?(piece.position, move) && piece.position[0] == move[0]
          lines[:up] << move
        when down?(piece.position, move) && piece.position[0] == move[0]
          lines[:down] << move
        when at_left?(piece.position, move) && piece.position[1] == move[1]
          lines[:left] << move
        when at_right?(piece.position, move) && piece.position[1] == move[1]
          lines[:right] << move
        end
      end
    end    

    lines.each do |key, value|
      if [:up, :left, :up_left_diagonal, :down_left_diagonal].include?(key) && !value.empty?
        found << pick_out(piece, value[-1], key)
      elsif [:down, :right, :up_right_diagonal, :down_right_diagonal].include?(key) && !value.empty?
        found << pick_out(piece, value[0], key)
      end
    end
    
    #p "#{piece.class}_#{piece.color} => #{found}"
    
    found.flatten.each do |move|
      piece.possible_moves.delete(move)
    end
    
    p "#{piece.class}_#{piece.color} => #{piece.possible_moves}"
  end
  
  def pick_out(piece, pos, sym)
    
    found = cell_with_foe?(piece, pos) ? [] : [pos]
    
    piece.possible_moves.each do |move|
      
      case sym
      when :up_left_diagonal
        found << move if up_left_diagonal?(pos, move)
      when :down_left_diagonal
        found << move if down_left_diagonal?(pos, move)
      when :up_right_diagonal
        found << move if up_right_diagonal?(pos, move)
      when :down_right_diagonal 
        found << move if down_right_diagonal?(pos, move)
      when :up
        found << move if up?(pos, move) && pos[0] == move[0]
      when :down
        found << move if down?(pos, move) && pos[0] == move[0]
      when :left
        found << move if at_left?(pos, move) && pos[1] == move[1]
      when :right
        found << move if at_right?(pos, move) && pos[1] == move[1]
      end
    end
    
    found
  end
  
  def up_left_diagonal?(piece_pos, target)
    left_diagonal?(piece_pos, target) &&
    up?(piece_pos, target)
  end
  
  def down_left_diagonal?(piece_pos, target)
    left_diagonal?(piece_pos, target) &&
    down?(piece_pos, target)
  end
  
  def up_right_diagonal?(piece_pos, target)
    right_diagonal?(piece_pos, target) &&
    up?(piece_pos, target)
  end
  
  def down_right_diagonal?(piece_pos, target)
    right_diagonal?(piece_pos, target) &&
    down?(piece_pos, target)
  end
  
  def left_diagonal?(piece_pos, target)
    on_diagonal?(piece_pos, target) &&
    at_left?(piece_pos, target)
  end
  
  def right_diagonal?(piece_pos, target)
    on_diagonal?(piece_pos, target) &&
    at_right?(piece_pos, target)    
  end
    
  def on_diagonal?(piece_pos, target)
    (piece_pos[0].ord - target[0].ord).abs == (piece_pos[1].to_i - target[1].to_i).abs
  end
  
  def up?(piece_pos, target)
    target[1].to_i - piece_pos[1].to_i > 0
  end
  
  def down?(piece_pos, target)
    target[1].to_i - piece_pos[1].to_i < 0
  end 
  
  def at_left?(piece_pos, target)
    ("a"..."#{piece_pos[0]}").include? target[0]
  end
   
  def at_right?(piece_pos, target)
    ("#{(piece_pos[0].ord + 1).chr}".."h").include? target[0]
  end
    
  def white?(target)
    (4..9).include? board.hash_map[target].values[0][1].ord.to_s(16)[3].to_i
  end
  
  def black?(target)
    ('a'..'f').include? board.hash_map[target].values[0][1].ord.to_s(16)[3]
  end
  
  def check?(piece)
    enemy = (piece.color == :white) ? player_black : player_white
    enemy_king = enemy.pieces[:king_e1] || enemy.pieces[:king_e8]
    
    if piece.possible_moves.include?(enemy_king.position)
      enemy_king.check = true
      enemy_king.checked_from << piece.position
    end
  end  
  
  def enemy(target, color)
    enemy = (color == :white) ? player_black : player_white
    enemy.pieces.detect { |_key, piece| piece.position == target }[1]
  end
  
  def cell_with_foe?(piece, move)
    black?(move) && piece.color  == :white || 
    white?(move) && piece.color == :black
  end
  
  def cell_with_friend?(piece, move)
    white?(move) && piece.color == :white || 
    black?(move) && piece.color == :black
  end
  
  def remove_passant(player)
    player.pieces.each { |_key, piece| piece.passant = [] if piece.is_a? Pawn }   
  end
end
