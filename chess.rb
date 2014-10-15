require 'debugger'
require 'colorize'


load './piece.rb'
load './pawn.rb'
load './stepping_pieces.rb'
load './sliding_pieces.rb'

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
      display_string = "   0  1  2  3  4  5  6  7 \n"
      alternate_color = true
      @board.each_with_index do |rows, row_index|
        display_string << "#{row_index} "
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
    piece_to_move = self[start_pos]
    raise StandardError.new("No piece there!") if piece_to_move.nil?
    unless piece_to_move.moves.include?(end_pos)
      raise StandardError.new("Can't move there!")   
    end
    move!(start_pos, end_pos)
    
  end
  
  def move!(start_pos, end_pos)
    piece_to_move = self[start_pos]
    self[start_pos] = nil
    piece_to_move.position = end_pos
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
  
  def checkmate?(color)
    pieces = @board.flatten.select {|piece| !piece.nil? && piece.color == color}
    # p pieces
    pieces.all? {|piece| piece.valid_moves.empty? }
    # p pieces
  end
  
end



b = Chessboard.new
b.display_board
b.move([6,5], [5,5])
b.move([1,4], [3,4])
b.move([6,6], [4,6])
b.move([0,3], [4,7])

b.display_board
p b.checkmate?("w")