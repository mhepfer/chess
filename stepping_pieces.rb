class SteppingPiece < Piece
  
  def moves
    move_array = []
    
    move_dirs.each do |offset|
      position = update_position(@position, offset)
      
      if on_board?(position) && 
              (!occupied?(position) || occupied_by_enemy?(position))
        move_array << position
      end
    end
    move_array
  end
  
end

class King < SteppingPiece

  attr_accessor :moved
  
  def initialize(board, position, color)
    super(board, position, color)
    moved = false
  end
  
  def move_dirs
    [[1,1], [-1, 1], [-1, -1], [1, -1], [1, 0], [0, 1], [-1, 0], [0, -1]]
  end
  
  def to_s
    @color == "w" ? "\u2654" : "\u265A"
  end
end

class Knight < SteppingPiece
  
  attr_reader :move_dirs
  
  def move_dirs
    [[2,1], [2,-1], [1,2], [1,-2], [-2,1], [-2,-1], [-1,2], [-1,-2]]
  end
  
  def to_s
    @color == "w" ? "\u2658" : "\u265E"
  end
  
end