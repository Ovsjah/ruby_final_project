require './lib/player'
require './lib/board'
require './lib/pieces'

module Factory
  include Pieces
  
  COMPONENTS = {
    :board => Board,
    :player => Player,
    :pawn => Pawn,
    :king => King,
    :queen => Queen,
    :bishop => Bishop,
    :knight => Knight,
    :rook => Rook
  }
  
  def self.create(component, options={})
    
    if component == :board
      COMPONENTS[component].new    
    elsif component == :player
      COMPONENTS[component].new(options[:name], options[:color])
    else
      COMPONENTS[component].new(options[:color], options[:type], options[:pos] = nil)
    end
    
  end
end
