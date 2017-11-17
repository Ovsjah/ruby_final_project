require 'board'

describe Board do

  before(:all) do
    @board = Board.new
  end
  
  describe '#new' do
    it "returns a board object" do
      expect(@board).to be_an_instance_of(Board)
    end
  end
  
  describe '#grid' do
    it "returns array" do
      expect(@board.grid.class).to eq(Array)
    end
  
    it "has 64 cells" do
      expect(@board.grid.size * @board.grid[0].size).to eq(64)
    end
  end
  
  describe '#colorize' do
    it "colorizes cells" do
      @board.grid.each_with_index do |row, row_idx|
        row.each_with_index do |cell, cell_idx|
          if row_idx.even? && cell_idx.even?
            expect(@board.colorize(cell, 46)).to eq("\e[46m   \e[0m")
          end
        end
      end
    end 
  end
  
  describe '#hash_map' do
    it "returns values associated with chess board coordinates" do
      @board.grid[0][6][1] = '♘'
      expect(@board.hash_map[:g1]).to eq({[0, 6]=>" ♘ "}) 
    end  
  end
  
  describe '#visualize' do
    it "prints human friendly board to the console" do
      expect(@board.visualize).to eq(nil)
    end
  end
end
