require 'colorize'

class Chessboard
  attr_accessor :board
  
  def initialize
    @board = Array.new(8){Array.new(8) {nil}}
    populate_board
  end
  
  def populate_board
    self[[0, 0]] = Rook.new(self, [0, 0], "b")
    self[[0, 7]] = Rook.new(self, [0, 7], "b")
    self[[7, 0]] = Rook.new(self, [7, 0], "w")
    self[[7, 7]] = Rook.new(self, [7, 7], "w")

    self[[0, 1]] = Knight.new(self, [0, 1], "b")
    self[[0, 6]] = Knight.new(self, [0, 6], "b")
    self[[7, 1]] = Knight.new(self, [7, 1], "w")
    self[[7, 6]] = Knight.new(self, [7, 6], "w")

    self[[0, 2]] = Bishop.new(self, [0, 2], "b")
    self[[0, 5]] = Bishop.new(self, [0, 5], "b")
    self[[7, 2]] = Bishop.new(self, [7, 2], "w")
    self[[7, 5]] = Bishop.new(self, [7, 5], "w")

    self[[0, 3]] = Queen.new(self, [0, 3], "b")
    self[[7, 3]] = Queen.new(self, [7, 3], "w")

    self[[0, 4]] = King.new(self, [0, 4], "b")
    self[[7, 4]] = King.new(self, [7, 4], "w")
    
    8.times do |y|
      self[[1, y]] = Pawn.new(self, [1, y], "b")
      self[[6, y]] = Pawn.new(self, [6, y], "w")
    end
    
    def display_board
      display_string = ""
      alternate_color = true
      @board.each_with_index do |rows, row_index|
        rows.each_with_index do |space, col_index|
          if alternate_color
            display_string << " ".on_black if space.nil?
            display_string << space.to_s.colorize(:white).on_black
            display_string << "  ".on_black
          else
            display_string << " ".on_red if space.nil?
            display_string << space.to_s.colorize(:white).on_red
            display_string << "  ".on_red
          end
          alternate_color = !alternate_color
          
        end
        display_string << "\n"
        alternate_color = !alternate_color
      end
      puts display_string
    end
    
  end
  
  def [](position)
    x,y = position
    @board[x][y]
  end
  
  def []=(position, piece)
    x,y = position
    @board[x][y] = piece
  end
  
  def in_check?(color)
    king_position = find_king(color)
    all_enemy_pieces(color).any? {|piece| piece.moves.include? king_position}
  end
  
  def all_enemy_pieces(color)
    result = []
    @board.each do |row|
      row.each do |piece|
        if piece != nil && piece.color != color
          result << piece 
        end
      end
    end
    result
  end
  
  def find_king(color)
    @board.each_with_index do |row, x|
      row.each_with_index do |piece, y|
        if piece.class == King && piece.color == color
          return piece.position
        end
      end
    end
  end
  
  def move(start_pos, end_pos)
    raise StandardError.new("No piece there!") if self[start_pos].nil?
    piece_to_move = self[start_pos]
    unless piece_to_move.moves.include?(end_pos)
      raise StandardError.new("Can't move there!")   
    end
    self[start_pos] = nil
    piece_to_move.position = end_pos
    unless self[end_pos].nil?
      captured_piece = self[end_pos]
      captured_piece.position = nil
    end
    self[end_pos] = piece_to_move
    
  end
  
  def dup
    board_dup = Chessboard.new
    board_dup.board = Array.new(8){Array.new(8) {nil}}
    self.board.each_with_index do |row, row_index|
      row.each_with_index do |piece, col_index|
        unless piece.nil?
          new_piece = piece.class.new(board_dup, [row_index,col_index], piece.color)
          board_dup[[row_index,col_index]] = new_piece
        end
      end
    end
    board_dup
  end
  
end

class Piece
  DIAGONALS = [[1,1], [-1, 1], [-1, -1], [1, -1]]
  ORTHOGONALS = [[1, 0], [0, 1], [-1, 0], [0, -1]]
  
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
    moves = self.moves
    moves.reject do |move|
      self.move_into_check?(move)
    end
  end

  def move_into_check?(pos)
    board_dup = self.board.dup
    board_dup[self.position] = nil
    board_dup[pos] = self
    board_dup.in_check?(self.color)
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
  
  def to_s
    @color == "w" ? "\u2659" : "\u265F"
  end
  
end