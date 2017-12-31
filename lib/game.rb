require 'json'
require './lib/factory'
require './lib/game_helpers'
require './lib/colorize'

class Game
  extend Factory  
  include Pieces  
  include GameHelpers
  
  attr_accessor :player_white, :player_black, :board
  
  def initialize
    @board = Factory.create(:board)
    @player_white = Factory.create(:player, {:name => nil, :color => :white})
    @player_black = Factory.create(:player, {:name => nil, :color => :black})
  end
  
  def save(player)

    json = JSON.dump({
      :player_white => player_white.name,
      :player_black => player_black.name,
      :turn => player.color,
      :white_pieces => pieces_saver(player_white),
      :black_pieces => pieces_saver(player_black)
    })
      
    File.open("#{player_white.name.downcase}_vs_#{player_black.name.downcase}.dat", 'w') do |file|
      file.write(json)
    end
    
    puts "Game saved. Good bye!"
    exit(0)
  end
  
  def load_game(name_white, name_black)
    data = File.read("#{name_white}_vs_#{name_black}.dat")
    data = JSON.load(data)
    
    player_white.name = data["player_white"]
    player_black.name = data["player_black"]
    
    turn = data["turn"].to_sym
    
    white_pieces = data["white_pieces"]
    black_pieces = data["black_pieces"]
    
    pieces_loader(player_white, white_pieces)
    pieces_loader(player_black, black_pieces)

    play(turn, false)
  rescue Errno::ENOENT
    puts "Sorry, you don't have any saved game!"
  end
  
  def introduction
    puts colorize("Hello, boys and girls, this is your old pal Stinky Wizzleteats. This is a game about a whale—no! This is a game about chess!", "1;31")
    puts "If you wanna to load a game. Just type '#{colorize("LOAD", "30;46")} #{colorize("Player White Name", "1;37")} vs #{colorize("Player Black Name", "1;30")}' or hit #{colorize("ENTER", "30;46")} to skip"
    print '>> '
    
    response = gets.split(/\s/)
    response.each { |word| word.downcase }
    
    if response.include? 'load'
      load_game(response[1], response[-1])
    else
      "So... You don't want to load a game."
    end
      
    puts "'QUIT' to quit a game"
    
    puts colorize("That's right! So enter your name for WHITE PLAYER!", "1;31") 
    print '>> '
    response_one = gets.chomp
    
    puts colorize("That's right! Now enter your name for BLACK PLAYER!", "1;31")
    print '>> '
    response_two = gets.chomp
    
    if response_one.upcase == 'QUIT' || response_two.upcase == 'QUIT'
      puts "Good bye!"
      exit(0)
    else
      player_white.name = response_one
      player_black.name = response_two
    end
  end
  
  def setup
    puts colorize("The game of chess started! Happy happy joy joy!", "1;31")
     
    [player_white, player_black].each do |player|
      player.pieces.each do |key, piece|
        place(piece)
      end
    end
  end
  
  def play(turn = nil, intro = true)
    
    introduction if intro
    
    setup
    
    loop do
      flag = false
      
      [player_white, player_black].each do |player|
        
        update_moves(player) unless flag
        
        if player.color != turn && !turn.nil?
          turn = nil
          next
        else
          turn = nil
        end
        
        king = king(player.color)      
        
        board.visualize
        
        puts "Enter #{colorize('SAVE', "30;46")} to save and quit"
        puts "Enter #{colorize('QUIT', "30;46")} to quit without saving"
        
        if player.color == :white
          puts "#{colorize("white turn", "1;37;40")} turn"
        else
          puts "#{colorize("black turn", "1;30;40")} turn"
        end
        
        exit(0) if game_over?(king)
                
        print '>> '
        
        move = gets.split(/\s/)
        
        if move[0].nil? || move[0].upcase == 'QUIT'
          puts colorize("Are you happy enough! Come on in again, pal!", "1;31")
          exit(0)
        elsif move[0].upcase == 'SAVE'
          save(player)
        end       
        
        begin
          start, finish = move[0].to_sym, move[1].to_sym
          piece = player.get(start, finish)
        rescue NoMethodError => flag
          puts "--> Enter a valid move! <--"
          redo
        end
                
        pick(piece)
        piece = player.move(piece, finish)
        place(piece)
        
        if piece.class == King && piece.moved == false
          castle_rook(player)
        end
        
        piece.moved = true if piece.class == King || piece.class == Rook
        
        if piece.is_a? Pawn

          unless piece.passant.is_a? Array
            pick(piece.passant) if piece.position[0] == piece.passant.position[0]
            remove_from_board(foe(player.color))
            remove_passant(player)
          end
                  
          if piece.promote
            new = false
            
            until new
              begin
                piece = pawn_promote(player, piece)
              rescue NoMethodError => new
                redo
              end
            end
            
            add(player, piece)
          end      
        end
        
        if king.check && piece.position == king.checked_from
          remove_from_board(foe(player.color))
        elsif !king.check
          remove_from_board(foe(player.color))
        end        
        
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
          flag = true  
          redo
        end
        
        update_moves(player)
      end
    end
  end 
  
  #private
  
  def update_moves(player, passant = true)
    
    player.pieces.each do |_key, piece|      
      piece.update_moves
      adjust(piece, passant)    
    end
    
    enemy_king = enemy_king(player.color)
    king = king(player.color) 
    
    tied_pieces = tied_pieces(player)
    adjust_tied_pieces_possible_moves(tied_pieces) unless tied_pieces.empty?
    
    king.stalemate = stalemate?(player)    
    king.mate = mate?(player)    
    enemy_king.check = player.pieces.any? { |_key, piece| enemy_king.checked_from = check?(piece) ? piece.position : nil }
  end
  
  def adjust(piece, passant)
    
    if piece.is_a? Pawn
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

    response = gets.chomp
    
    if piece.promote.include?(response)
      choice = response.chomp.to_sym
    end
    
    new_piece = Factory.create(choice, {:color => player.color, :type => 0})
    
    new_piece.position = piece.position
    
    place(new_piece)
   
    remove(player, piece)
    
    new_piece   
  end
  
  def remove_passant(player)
    player.pieces.each { |_key, piece| piece.passant = [] if piece.is_a? Pawn }   
  end
  
  def adjust_tied_pieces_possible_moves(tied_pieces)
    tied_pieces.each do |pos, tied_piece|

      if tied_piece.is_a? Pawn
        cells_between = cells_between(tied_piece.position, pos)
        tied_piece.possible_moves.keep_if { |move| cells_between.include? move }
      elsif tied_piece.class == Knight
        tied_piece.possible_moves.delete_if { |move| move != pos }
      else
        cells_between = cells_between(king(tied_piece.color).position, pos)
        tied_piece.possible_moves.keep_if { |move| cells_between.include? move }
      end
    end
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
    
    if piece.class == King
      adjust_king_moves(piece)
      castling(piece)
    end
  end
  
  def tied_pieces(player)
    color = player.color

    lines_with_king(color).each_with_object({}) do |line, tied_pieces|
      tied_pos = line[0][1].detect { |pos| pos != king(color).position }
      tied_piece = player.pieces.detect { |_key, piece| piece.position == tied_pos } unless tied_pos.nil?
      tied_pieces[line[1]] = tied_piece[1] unless tied_piece.nil?
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
  
        lines_with_king << [line , enemy_piece.position] unless line.nil? 
      end
      
      enemy_piece.possible_moves = copy
    end
  end
    
  def adjust_king_moves(piece)
    lines_with_king = lines_with_king(piece.color)

    foe(piece.color).pieces.each do |_key, enemy_piece|
 
      if enemy_piece.class == Knight
        copy = enemy_piece.possible_moves
        enemy_piece.update_moves
      end
      
      piece.possible_moves.delete_if do |move|
        
        if enemy_piece.is_a? Pawn
          enemy_piece.taking.include? move
        else          
          enemy_piece.possible_moves.include?(move) || lines_with_king.any? { |line| line[0][1].include?(move) }
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
  
  def cells_between(start, finish)
  
    board.hash_map.each_with_object([]) do |pair, selected|
      key = pair[0]
      
      case
      when up_left_diagonal?(start, key) && start != key
        selected << key if up_left_diagonal?(start, finish) && key[1] <= finish[1]
      when down_left_diagonal?(start, key) && start != key
        selected << key if down_left_diagonal?(start, finish) && key[1] >= finish[1]
      when up_right_diagonal?(start, key) && start != key
        selected << key if up_right_diagonal?(start, finish) && key[1] <= finish[1]
      when down_right_diagonal?(start, key) && start != key
        selected << key if down_right_diagonal?(start, finish) && key[1] >= finish[1]
      when up?(start, key) && start[0] == key[0] && start != key
        selected << key if up?(start, finish) && key[0] == finish[0] && key[1] <= finish[1]
      when down?(start, key) && start[0] == key[0] && start != key
        selected << key if down?(start, finish) && key[0] == finish[0] && key[1] >= finish[1]
      when at_left?(start, key) && start[1] == key[1] && start != key
        selected << key if at_left?(start, finish) && key[1] == finish[1] && key[0] >= finish[0]
      when at_right?(start, key) && start[1] == key[1] && start != key
        selected << key if at_right?(start, finish) && key[1] == finish[1] && key[0] <= finish[0]
      end
    end    
  end
end
