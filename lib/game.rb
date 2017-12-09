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
        
        king = king(player.color)
        
        board.visualize
        
        puts "#{player.color} turn"
        p "possible_moves => #{player.pieces[:queen_d8].possible_moves}" if player.color == :black
        #p player_black.pieces
        #if king.mate
          #puts "#{(foe(player.color).color).capitalize} won!"
          #exit(0)
        if king.stalemate
          puts "Draw! Stalemate!"
          exit(0)
        elsif king.check
          puts "Achtung! Check! Checked from #{king.checked_from}"
        end
                
        print '>> '
        
        move = gets.split(/\s/)
        
        start, finish = move[0].to_sym, move[1].to_sym
        
        begin
          piece = player.get(start, finish)
        rescue NoMethodError
          puts "--> Enter a valid move! <--"
          redo
        end
                
        pick(piece)
        piece = player.move(piece, finish)
        place(piece)
        
        if piece.is_a? Pawn

          unless piece.passant.is_a? Array
            pick(piece.passant) if piece.position[0] == piece.passant.position[0]
          end
                  
          if piece.promote
            piece = pawn_promote(player, piece) 
            add(player, piece)
          end      
               
          remove_passant(player)
        end
        
        remove_from_board(foe(player.color), enemy_king(player.color))
        update_moves(foe(player.color), false)
        
        if king.check

          update_moves(foe(player.color), false)
          
          if king.check
            
            pick(piece)        
            piece = player.move(piece, piece.prev_pos)
            
            enemy_piece =
              begin 
                enemy_piece(piece.prev_pos, player.color)
              rescue NoMethodError
                nil
              end
              
            place(piece)
            place(enemy_piece) unless enemy_piece.nil?
            
            redo
          end
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
  
  def remove_from_board(player, king)
  
    player.pieces.each do |key, piece|
        
      if king.check && piece.position == king.checked_from
        remove(player, piece, key)
      elsif !king.check
        remove(player, piece, key)
      end
      
    end
  end
  
  def update_moves(player, passant = true)
    
    player.pieces.each do |_key, piece|      
      piece.update_moves
      adjust(piece, passant)    
    end
    
    enemy_king = enemy_king(player.color)
    king = king(player.color) 
    
    tied_piece(player)
    
    king.stalemate = stalemate?(player)
    
    #king.mate = mate?(player)
    
    enemy_king.check =    
      player.pieces.any? do |_key, piece|
        enemy_king.checked_from = check?(piece) ? piece.position : nil  
      end
  end
  
  def adjust(piece, passant)
    
    if piece.class == Pawn
      adjust_pawn_possible_moves(piece)
      adjust_pawn_taking(piece)
      adjust_pawn_taking_en_passant(piece) if piece.taking_en_passant && passant
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
    piece.possible_moves.each_with_index do |move, idx|
    
      if  board.hash_map[move].values[0] != "   " && idx == 0
        piece.possible_moves = []
      elsif board.hash_map[move].values[0] != "   " && idx == 1
        piece.possible_moves.delete(move)
      end
      
    end
  end
  
  def adjust_pawn_taking(piece)
    piece.taking.each do |target|     
      piece.possible_moves << target if cell_with_foe?(piece, target)
    end
  end
  
  def adjust_pawn_taking_en_passant(piece)

    piece.passant = [] unless piece.passant.is_a? Array
    
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
    
    if piece.taking_en_passant && piece.passant.is_a?(Array)
      piece.taking_en_passant.each do |target|
        piece.passant << enemy_piece(target, piece.color) if cell_with_foe?(piece, target) 
      end
    end
  end
  
  def adjust_knight_possible_moves(piece)
    piece.possible_moves.delete_if do |move| 
      cell_with_friend?(piece, move)
    end
  end
  
  def adjust_possible_moves(piece)
    lines = directions(piece)
    delete_moves(lines, piece)
    adjust_king_moves(piece) if piece.class == King
  end
  
  def tied_piece(player)
    color = player.color

    lines_with_king(color).each do |line|

      tied_pos = line[0].detect { |pos| pos != king(color).position }
       
      unless tied_pos.nil?
        tied_piece = player.pieces.detect { |_key, piece| piece.position == tied_pos }[1]
        tied_piece.possible_moves.delete_if { |move| move != line[1] }
      end
    end
  end
  
  def lines_with_king(color)
    
    foe(color).pieces.each_with_object([]) do |pair, lines_with_king|
      enemy_piece = pair[1]
      copy = enemy_piece.possible_moves
      enemy_piece.update_moves
      
      unless enemy_piece.is_a? Pawn
        lines = directions(enemy_piece)
        line = lines.detect { |_key, value| value.include? king(color).position }
  
        lines_with_king << [line[1] , enemy_piece.position] unless line.nil? 
      end
      
      enemy_piece.possible_moves = copy
    end
  end
    
  def adjust_king_moves(piece)
    lines_with_king = lines_with_king(piece.color)
    
    foe(piece.color).pieces.each do |_key, enemy_piece|
      
      unless lines_with_king.any? { |line| line.include? enemy_piece.position }
        copy = enemy_piece.possible_moves
        enemy_piece.update_moves
      end
      
      piece.possible_moves.delete_if do |move|
        
        if enemy_piece.is_a? Pawn
          enemy_piece.taking.include? move
        else          
          enemy_piece.possible_moves.include?(move) || lines_with_king.any? { |line| line[0].include?(move) }
        end
        
      end

      enemy_piece.possible_moves = copy unless copy.nil?
    end
  end
  
  def directions(piece)
  
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
    
    lines  
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
  
  def delete_moves(lines, piece)
  
    found = []
    
    lines.each do |key, value|
    
      if [:up, :left, :up_left_diagonal, :down_left_diagonal].include?(key) && !value.empty?
        found << pick_out(piece, value[-1], key)
      elsif [:down, :right, :up_right_diagonal, :down_right_diagonal].include?(key) && !value.empty?
        found << pick_out(piece, value[0], key)
      end
      
    end
    
    found.flatten.each do |move|
      piece.possible_moves.delete(move)
    end    
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
    piece_pos != target &&
    ("a"..."#{piece_pos[0]}").include?(target[0])
  end
   
  def at_right?(piece_pos, target)
    piece_pos != target &&
    ("#{(piece_pos[0].ord + 1).chr}".."h").include?(target[0])
  end
    
  def white?(target)
    (4..9).include? board.hash_map[target].values[0][1].ord.to_s(16)[3].to_i
  end
  
  def black?(target)
    ('a'..'f').include? board.hash_map[target].values[0][1].ord.to_s(16)[3]
  end
  
  def check?(piece)
    piece.possible_moves.include?(enemy_king(piece.color).position) 
  end  
  
  def stalemate?(player)
    player.pieces.all? { |_key, piece| piece.possible_moves == [] }
  end
  
  def mate?(player)
    king = king(player.color)
    #p up_left_diagonal?(king.checked_from, king.position) unless king.checked_from.nil?
    king.check && king.possible_moves.empty? &&
    player.pieces.none? { |_key, piece| piece.possible_moves.include?(king.checked_from) }
  end
          
  def enemy_king(color)
    enemy = foe(color)
    enemy.pieces[:king_e1] || enemy.pieces[:king_e8]
  end
  
  def king(color)
    color == :white ? player_white.pieces[:king_e1] : player_black.pieces[:king_e8]
  end
           
  def enemy_piece(target, color)
    foe(color).pieces.detect { |_key, piece| piece.position == target }[1]
  end
  
  def foe(color)
    color == :white ? player_black : player_white
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
