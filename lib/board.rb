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
