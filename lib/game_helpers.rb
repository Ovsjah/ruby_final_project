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
    
    if left_rook && king.moved == false && left_rook.moved == false && !king.check
      if west_side?(player.color)
        king.possible_moves << king.castling_moves[0]
      end
    end
    
    if right_rook && king.moved == false && right_rook.moved == false && !king.check
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
    c, d = color == :white ? [:c1, :d1] : [:c8, :d8]
    include_castling_moves?(color, c, d)
  end
  
  def east_side?(color)
    f, g = color == :white ? [:f1, :g1] : [:f8, :g8]
    include_castling_moves?(color, f, g)
  end

  def include_castling_moves?(color, cell_a, cell_b)
  
    board.hash_map[cell_a].values[0] == "   " && 
    board.hash_map[cell_b].values[0] == "   " &&
    foe(color).pieces.none? do |_k, p|
      if p.class == Pieces::Pawn
        p.taking.include?(cell_a) || p.taking.include?(cell_b)
      else 
        p.possible_moves.include?(cell_a) || p.possible_moves.include?(cell_b)
      end
    end
  end

  def game_over?(king)
    if king.mate
      puts "#{(foe(king.color).color).capitalize} won! Mate!"
      true
    elsif king.stalemate
      puts "Draw! Stalemate!"
      true
    elsif king.check
      puts "Achtung! Check! Checked from #{king.checked_from}"
      false
    end   
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
    name = name[8..-1] if name.include? "pieces::"
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
  
  def pieces_saver(player)
    player.pieces.each_with_object({}) do |piece, pieces|
      if piece[1].class == Pieces::Pawn && piece[1].passant.class == Pieces::Pawn       
        pieces[piece[0]] = [piece[1].position, piece[1].passant.position]
      elsif (piece[1].class == Pieces::King || piece[1].class == Pieces::Rook) && piece[1].moved
        pieces[piece[0]] = [piece[1].position, piece[1].moved]
      else
        pieces[piece[0]] = piece[1].position
      end
    end
  end
  
  def pieces_loader(player, pieces)
    diff = player.pieces.keys - pieces.keys.map(&:to_sym)
    new_pieces = pieces.keys.map(&:to_sym) - player.pieces.keys
    diff.each { |item| player.pieces.delete(item) }
    
    new_pieces.each do |key|
      new_piece = Factory.create(key[0..-4].to_sym, {:color => player.color, :type => 0})
      new_piece.position = pieces[key.to_s].to_sym
      place(new_piece)
      add(player, new_piece)
    end
    
    pieces.each do |k, v|
      piece = player.pieces[k.to_sym]
      if v.is_a? Array        
        piece.position = v[0].to_sym
        if piece.class == Pieces::Pawn
          passant_position = v[1].to_sym
          passant = foe(player.color).pieces.detect { |_k, p| p.possible_moves.include? passant_position }[1]
          p passant
          piece.passant = [passant]
        elsif piece.class == Pieces::King || piece.class == Pieces::Rook
          piece.moved = v[1]
        end
      else
        piece.position = v.to_sym unless piece.nil?
      end
    end
  end
end
