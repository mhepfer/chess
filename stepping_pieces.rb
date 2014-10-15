class SteppingPiece < Piece
  
  def moves
    move_array = []
    move_dirs.each do |offset|
      position = update_position(@position, offset)
      unless invalid?(position)
        move_array << position 
      end
    end
    move_array
  end
  
end

class King < SteppingPiece
  def move_dirs
    DIAGONALS + ORTHOGONALS
  end
  
  def to_s
    @color == "w" ? "\u2654" : "\u265A"
  end
end

class Knight < SteppingPiece
  
  def move_dirs
    [[2,1],[2,-1],[1,2],[1,-2],[-2,1],[-2,-1],[-1,2],[-1,-2]]
  end
  
  def to_s
    @color == "w" ? "\u2658" : "\u265E"
  end
  
end