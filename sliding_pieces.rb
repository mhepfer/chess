class SlidingPiece < Piece
  DIAGONALS = [[1,1], [-1, 1], [-1, -1], [1, -1]]
  ORTHOGONALS = [[1, 0], [0, 1], [-1, 0], [0, -1]]

  def moves
    move_array = []
    move_dirs.each do |offset|
      position = update_position(@position, offset)
      until invalid?(position)
        move_array << position
        position = update_position(position, offset)
      end
      if on_board?(position) && @board[position].color != self.color
       move_array << position 
     end
    end
    move_array
  end
end

class Rook < SlidingPiece
  
  attr_accessor :moved
  
  def initialize(board, position, color)
    super(board, position, color)
    moved = false
  end
  
  def move_dirs
    ORTHOGONALS
  end
  
  def to_s
    @color == "w" ? "\u2656" : "\u265C"
  end
end

class Bishop < SlidingPiece
  def move_dirs
    DIAGONALS
  end 
  
  def to_s
    @color == "w" ? "\u2657" : "\u265D"
  end
end

class Queen < SlidingPiece
  def move_dirs
    DIAGONALS + ORTHOGONALS
  end
  
  def to_s
    @color == "w" ? "\u2655" : "\u265B"
  end
end