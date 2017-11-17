require './lib/player'
require './lib/board'
require './lib/pieces'
require './lib/factory'
require './lib/game'



game = Game.new
#p game.player_white.pieces[:king_e1]
game.play
