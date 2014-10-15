class SlidingPiece < Piece

  def moves
    move_array = []
    move_dirs.each do |offset|
      position = update_position(@position, offset)
      until invalid?(position)
        move_array << position #unless position == @position
        #we need to stop adding moves after we encouter a friendly or enemy
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