module GameHelpers
  
  def enemy_king(color)
    enemy = foe(color)
    enemy.pieces[:king_e1] || enemy.pieces[:king_e8]
  end
  
  def king(color)
    color == :white ? player_white.pieces[:king_e1] : player_black.pieces[:king_e8]
  end

  def castling(king)
    player = king.color == :white ? player_white : player_black
     
    left_rook = player.pieces[:rook_a1] || player.pieces[:rook_a8]
    right_rook = player.pieces[:rook_h1] || player.pieces[:rook_h8]
    
    if king.moved == false && left_rook.moved == false && !king.check
      if west_side?(player.color)
        king.possible_moves << king.castling_moves[0]
      end
    end
    
    if king.moved == false && right_rook.moved == false && !king.check
      if east_side?(player.color)
        king.possible_moves << king.castling_moves[1]
      end
    end      
  end
  
  def castle_rook(player)
    king = king(player.color)
    rook =
      if king.position == :c1 || king.position == :c8
        player.pieces[:rook_a1] || player.pieces[:rook_a8]
      elsif king.position == :g1 || king.position == :g8
        player.pieces[:rook_h1] || player.pieces[:rook_h8]
      end
      
    if rook
      pick(rook)
    
      rook =
        case rook.position
        when :a1
          player.move(rook, :d1)
        when :h1
          player.move(rook, :f1)
        when :a8
          player.move(rook, :d8)
        when :h8
          player.move(rook, :f8)
        end
       
      place(rook)
    end
  end
  
  def west_side?(color)
    b, c, d = color == :white ? [:b1, :c1, :d1] : [:b8, :c8, :d8]
  
    board.hash_map[b].values[0] == "   " &&
    board.hash_map[c].values[0] == "   " && 
    board.hash_map[d].values[0] == "   " &&
    foe(color).pieces.none? { |_k, p| p.possible_moves.include?(d) || p.possible_moves.include?(c) }
  end
  
  def east_side?(color)
    f, g = color == :white ? [:f1, :g1] : [:f8, :g8]
    
    board.hash_map[f].values[0] == "   " &&
    board.hash_map[g].values[0] == "   " &&
    foe(color).pieces.none? { |_k, p| p.possible_moves.include?(f) || p.possible_moves.include?(g) }
  end

  def check?(piece)
    piece.possible_moves.include?(enemy_king(piece.color).position) 
  end  
  
  def stalemate?(player)
    player.pieces.all? { |_key, piece| piece.possible_moves == [] }
  end
  
  def mate?(player)
    king = king(player.color)
    
    if king.check && king.possible_moves.empty?
      pieces = []
      
      lines_with_king = lines_with_king(player.color)
      cells_between = cells_between(king.position, king.checked_from)

      unless cells_between.nil?
        cells_between.each do |target|
          player.pieces.each do |key, piece|
            pieces << piece if piece.possible_moves.include?(target)   
          end
        end
      end

      pieces.uniq.empty?
    else
      false
    end
    
  end 
           
  def enemy_piece(target, color)
    foe(color).pieces.detect { |_key, piece| piece.position == target }[1]
  end
  
  def foe(color)
    color == :white ? player_black : player_white
  end
  
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

   p player.pieces.delete(key) if board.grid[coord[0]][coord[1]][1] != piece.char
  end
  
  def remove_from_board(player)  
    player.pieces.each do |key, piece|
      remove(player, piece, key)
    end
  end
  
  def cell_with_foe?(piece, move)
    black?(move) && piece.color  == :white || 
    white?(move) && piece.color == :black
  end
  
  def cell_with_friend?(piece, move)
    white?(move) && piece.color == :white || 
    black?(move) && piece.color == :black
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
end
