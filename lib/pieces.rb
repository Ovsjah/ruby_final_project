module Pieces
  class Pawn

    CHARS = {
      :white => [:a2, :b2, :c2, :d2, :e2, :f2, :g2, :h2, "\u2659"],
      :black => [:a7, :b7, :c7, :d7, :e7, :f7, :g7, :h7, "\u265f"]
    }
        
    attr_accessor :color, :char, :position, :prev_pos, :passant, :possible_moves
  
    def initialize(color, type)
      @color = color
      @char = CHARS[color][-1]
      @position = CHARS[color][type]
      @prev_pos = nil
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
    
      track =
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


  class Knight
    CHARS = {:white => [:b1, :g1, "\u2658"], :black => [:b8, :g8, "\u265e"]}
  
    attr_accessor :color, :char, :position, :prev_pos, :possible_moves
  
    def initialize(color, type)
      @color = color
      @char = self.class::CHARS[color][-1]
      @position = self.class::CHARS[color][type]     
      @prev_pos = nil  
      @possible_moves = update_moves
    end
  
    def alts
      alts = [-2, -1, 1, 2].permutation(2).select { |a, b| a.abs != b.abs }
    end
  
    def update_moves
      a = position[0]
      b = position[1].to_i
    
      @possible_moves = alts.map do |alt|

        if alt[0] < 0
          "#{(a.ord - alt[0].abs).chr}#{b - alt[1]}".to_sym
        else
          "#{(a.ord + alt[0].abs).chr}#{b - alt[1]}".to_sym
        end
      end
    
      @possible_moves.delete_if { |move| move.size == 3 || !move[0].between?('a', 'h') || !move[1].between?('1', '8') }
    end
  end


  class King < Knight
    CHARS = {:white => [:e1, "\u2654"], :black => [:e8, "\u265a"]}
  
    attr_accessor :color, :char, :moved, :mate, :stalemate, :check, :checked_from, :position, :possible_moves
  
    def initialize(color, type)
      super
      @moved = false
      @mate = false
      @stalemate = false
      @check = false
      @checked_from = nil
    end
    
    def castling_moves
      @color == :white ? [:c1, :g1] : [:c8, :g8]
    end
    
    def alts
      alts = [-1, 0, 0,  1].repeated_permutation(2).uniq.delete_if { |el| el == [0, 0] }
    end
  end


  class Queen < Knight
    CHARS = {:white => [:d1, "\u2655"], :black => [:d8, "\u265b"]}
  
    def alts
      (-7..7).to_a.repeated_permutation(2).select { |a, b| (a.abs == b.abs || a == 0 || b == 0) && !(a == 0 && b == 0) }
    end
  end


  class Bishop < Knight
    CHARS = {:white => [:c1, :f1, "\u2657"], :black => [:f8, :c8, "\u265d"]}
  
    def alts
      (-7..7).to_a.repeated_permutation(2).select { |a, b| (a.abs == b.abs) && !(a == 0 && b == 0) }
    end
  end


  class Rook < Knight
    CHARS = {:white => [:a1, :h1, "\u2656"], :black => [:h8, :a8, "\u265c"]}
    
    attr_accessor :moved
    
    def initialize(color, type)
      super
      @moved = false
    end
    
    def alts
      (-7..7).to_a.repeated_permutation(2).select { |a, b| (a == 0 || b == 0) && !(a == 0 && b == 0) }
    end
  end
end
