#!/usr/bin/env ruby

require './piece'
require './pawn'
require './stepping_pieces'
require './sliding_pieces'
require './chess'

class ChessGame
  
  def initialize
    @board = Chessboard.new
    @player1 = HumanPlayer.new("w")
    @player2 = HumanPlayer.new("b")
  end
  
  def play_game
    current_player = @player1
    until over?
      @board.display_board
      begin
        move = current_player.get_move
        if move == "0-0" || move == "0-0-0"
          @board.castle(move, current_player.color)
        else
          @board.move(move[0], move[1], current_player.color)
        end
      rescue MoveError => e
        puts e
        retry
      end
      current_player = switch(current_player)
    end
    
    congratulate(switch(current_player))
  end
  
  def congratulate(player)
    puts "#{player.color} wins!"
  end
  
  def switch(player)
    player == @player1 ? @player2 : @player1
  end
  
  def over?
    @board.checkmate?("w") || @board.checkmate?("b")
  end
  
end

class HumanPlayer
  class InputError < StandardError; end
  
  TRANSLATION_HASH_COLS = { '8' => 0, '7' => 1, '6' => 2, '5' => 3, '4' => 4, '3' => 5, '2' => 6, '1' => 7}
  TRANSLATION_HASH_ROWS = { 'a' => 0, 'b' => 1, 'c' => 2, 'd' => 3, 'e' => 4, 'f' => 5, 'g' => 6, 'h' => 7}
  attr_reader :color
  
  def initialize(color)
    @color = color
  end
  
  def get_move
    start_pos = nil
    end_pos = nil
    begin
      p "What is the location of the piece you would like to move? ex. a1"
      start_pos = gets_input
    rescue InputError => e
      puts e
      retry
    end
    begin
      p "Where would you like to go? g7"
      end_pos = gets_input
    rescue InputError => e
      puts e
      retry  
    end
    
    if start_pos == "0-0" || start_pos == "0-0-0"
      start_pos
    else
      start_coord = [TRANSLATION_HASH_COLS[start_pos[1]], TRANSLATION_HASH_ROWS[start_pos[0]]]
      end_coord = [TRANSLATION_HASH_COLS[end_pos[1]], TRANSLATION_HASH_ROWS[end_pos[0]]]
      [start_coord, end_coord]
    end
    
  end
  
  def gets_input
    pos = gets.chomp
    raise InputError.new("That's not what I asked for....") unless wellformed?(pos)
    pos
  end
  
  def wellformed?(pos)
    return true if pos == "0-0" || pos == "0-0-0"
    return false unless pos.length == 2
    return false unless pos[0].between?('a', 'h')
    return false unless pos[1].between?('1', '8')
    true
  end

end

if __FILE__ == $PROGRAM_NAME
  
  ChessGame.new.play_game

end
  