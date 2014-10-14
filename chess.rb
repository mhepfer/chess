class Chess_board
  def initialize
    @board = Array.new(8){Array.new(8) {nil}}
  end
  
  def position
    
  end
  
  def [](position)
    x,y = position
    self[x][y]
  end
  
end

class Piece
  DIAGONALS = [[1,1], [-1, 1], [-1, -1], [1, -1]]
  ORTHOGONALS = [[1, 0], [0, 1], [-1, 0], [0, -1]]


  def initialize(board, position, color)
    @board, @position, @color = board, position, color
  end
  
  def occupied_by_enemy?(position)
    if @board[position].nil?
      return false
    end
    
    self.color != board[position].color
  end

  private
  
  def update_position(position, offset)
    x,y = position
    delta_x, delta_y = offset
    [delta_x + x, y + delta_y]
  end
  
  def invalid?(position)
    occupied?(position) || !on_board?(position)
  end
  
  def occupied?(position)
    false
  end
  
  def on_board?(position)
    position.first.between?(0, 7) && position.last.between?(0, 7)
  end
end

class SlidingPiece < Piece

  def moves
    move_array = []
    
    move_dirs.each do |offset|
      position = @position
      until invalid?(position)
        move_array << position unless position == @position
        position = update_position(position, offset)
      end
    end
    move_array
  end
  
end

class Rook < SlidingPiece
  def move_dirs
    ORTHOGONALS
  end
end

class Bishop < SlidingPiece
  def move_dirs
    DIAGONALS
  end 
end

class Queen < SlidingPiece
  def move_dirs
    DIAGONALS + ORTHOGONALS
  end
end

class SteppingPiece < Piece
  
  def moves
    move_array = []
    p move_dirs
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
end

class Knight < SteppingPiece
  
  def move_dirs
    [[2,1],[2,-1],[1,2],[1,-2],[-2,1],[-2,-1],[-1,2],[-1,-2]]
  end
  
end

class Pawn < Piece
  def move_dirs
    [[1, 0], [2, 0]]
  end
  
  def attack_dirs
    [[1, 1], [1, -1]]
  end
  
  def moves
    offset_array = []
    if @color == "w"
      move_directions = move_dirs.map{ |offset| [offset.first * -1, offset.last] }
      attack_directions = attack_dirs.map{ |offset| [offset.first * -1, offset.last] }
      at_home = @position[0] == 6
    else
      move_directions = move_dirs
      attack_directions = attack_dirs
      at_home = @position[0] == 1
    end
    
    offset_array << move_directions.first
    if at_home
      offset_array << move_directions.last
    end
    
    attack_directions.each do |possible_space|
      offset_array << possible_space #if occupied_by_enemy?(possible_space)
    end
    
    offset_array.map{|offset| update_position(@position, offset)}
  end
  
end