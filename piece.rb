class Piece
  
  attr_reader :color
  attr_accessor :position, :board
  
  def initialize(board, position, color)
    @board, @position, @color = board, position, color
  end
  
  def occupied_by_enemy?(position)
    if @board[position].nil?
      return false
    end
    
    self.color != board[position].color
  end
  
  def valid_moves
    moves.reject do |move|
      self.move_into_check?(move)
    end
  end

  def move_into_check?(pos)
    board_dup = self.board.dup
    board_dup.move!(self.position, pos)
    board_dup.in_check?(self.color)
  end
  
  def occupied?(position)
    !!@board[position]
  end
  
  private
  
  def update_position(position, offset)
    x,y = position
    delta_x, delta_y = offset
    [delta_x + x, y + delta_y]
  end
  
  def invalid?(position)
     !on_board?(position) || occupied?(position)
  end
  
  
  
  def on_board?(position)
    position.first.between?(0, 7) && position.last.between?(0, 7)
  end

end