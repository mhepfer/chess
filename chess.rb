
require 'colorize'
class MoveError < StandardError; end

class Chessboard
  
  attr_accessor :board
  
  def initialize(populate = true)
    @board = Array.new(8){ Array.new(8) }
    populate_board if populate
  end
  
  def populate_board
    rook_array = [[[0, 0],"b"], [[0, 7], "b"], [[7, 0], "w"], [[7, 7], "w"]]
    rook_array.each {
              |rook| self[rook[0]] = Rook.new(self, rook[0], rook[1]) }
    
    knight_array = [[[0, 1],"b"], [[0, 6], "b"], [[7, 1], "w"], [[7, 6], "w"]]
    knight_array.each {
             |knight| self[knight[0]] = Knight.new(self, knight[0], knight[1]) }

    bishop_array = [[[0, 2],"b"], [[0, 5], "b"], [[7, 2], "w"], [[7, 5], "w"]]
    bishop_array.each {
             |bishop| self[bishop[0]] = Bishop.new(self, bishop[0], bishop[1]) }

    self[[0, 3]] = Queen.new(self, [0, 3], "b")
    self[[7, 3]] = Queen.new(self, [7, 3], "w")

    self[[0, 4]] = King.new(self, [0, 4], "b")
    self[[7, 4]] = King.new(self, [7, 4], "w")
    
    8.times do |y|
      self[[1, y]] = Pawn.new(self, [1, y], "b")
      self[[6, y]] = Pawn.new(self, [6, y], "w")
    end
  end
  
  def display_board
    display_string = "   a  b  c  d  e  f  g  h \n"
    alternate_color = true
    @board.each_with_index do |rows, row_index|
      display_string << "#{ (row_index-8).abs } "
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
    all_enemy_pieces(color).any? { |piece| piece.moves.include? king_position }
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
  
  def move(start_pos, end_pos, color)
    piece_to_move = self[start_pos]
    raise MoveError.new("No piece there!") if piece_to_move.nil?
    raise MoveError.new("That piece doesn't belong to you!") unless 
            piece_to_move.color == color
    unless piece_to_move.moves.include?(end_pos)
      raise MoveError.new("Can't move there!")   
    end
    
    if piece_to_move.class == Rook || piece_to_move.class == King
      piece_to_move.moved = true
    end
      
    move!(start_pos, end_pos)
    
    if piece_to_move.class == Pawn && 
          (piece_to_move.position[0] == 0 ||  piece_to_move.position[0] == 7)
      promote_pawn(piece_to_move)
    end
      
  end
  
  def move!(start_pos, end_pos)
    piece_to_move = self[start_pos]
    self[start_pos] = nil
    piece_to_move.position = end_pos
    self[end_pos] = piece_to_move
  end
  
  def promote_pawn(piece_to_upgrade)
    p "Which type of piece would you like? Queen (q), Knight (k), Bishop (b), Rook(r)"
    begin
      piece = gets.chomp
      raise InputError.new("q k b or r") unless ["q", "k", "b", "r"].include?(piece)
    rescue InputError => e
      puts e
      retry
    end
    case piece
    when 'q'
      self[piece_to_upgrade.position] = Queen.new(self, piece_to_upgrade.position, piece_to_upgrade.color)
    when 'k'
      self[piece_to_upgrade.position] = Knight.new(self, piece_to_upgrade.position, piece_to_upgrade.color)
    when 'b'
      self[piece_to_upgrade.position] = Bishop.new(self, piece_to_upgrade.position, piece_to_upgrade.color)
    when 'r'
      self[piece_to_upgrade.position] = Rook.new(self, piece_to_upgrade.position, piece_to_upgrade.color)
    end
  end
  
  def dup
    board_dup = Chessboard.new(false)
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
    pieces.all? {|piece| piece.valid_moves.empty? }
  end
  
  def castle(type, color)
    if type == "0-0"
      kingside_castle(color)
    else
      queenside_castle(color)
    end
  end
  
  def kingside_castle(color)
    raise MoveError.new("Castle can't move out of check") if in_check?(color)
    raise MoveError.new("Can't castle. Pieces in between king and rook") if pieces_in_way?(color, :kingside)
    #raise MoveError.new("Castle can't move over check") if over_check?(color, :kingside)
    raise MoveError.new("Can't castle. King has moved") unless king_unmoved?(color)
    raise MoveError.new("Can't castle. Rook has moved") unless rook_unmoved?(color, :kingside)
    
    if color == 'w'
      move!([7, 4], [7, 6])
      self[[7, 6]].moved = true
      move!([7, 7], [7, 5])
      self[[7, 5]].moved = true
    else
      move!([0, 4], [0, 6])
      self[[0, 6]].moved = true
      move!([0, 7], [0, 5])
      self[[0, 5]].moved = true
    end
  end
  
  def queenside_castle(color)
    raise MoveError.new("Castle can't move out of check") if in_check?(color)
    raise MoveError.new("Can't castle. Pieces in between king and rook") if pieces_in_way?(color, :queenside)
    #sraise MoveError.new("Castle can't move over check") if over_check?(color, :queenside)
    raise MoveError.new("Can't castle. King has moved") unless king_unmoved?(color)
    raise MoveError.new("Can't castle. Rook has moved") unless rook_unmoved?(color, :queenside)
    if color == 'w'
      move!([7, 4], [7, 2])
      self[[7, 2]].moved = true
      move!([7, 0], [7, 3])
      self[[7, 3]].moved = true
    else
      move!([0, 4], [0, 2])
      self[[0, 2]].moved = true
      move!([0, 0], [0, 3])
      self[[0, 3]].moved = true
    end
  end
  
  def king_unmoved?(color)
    if color == "b"
      self[[0,4]].class == King && !self[[0, 4]].moved
    else
      self[[7,4]].class == King && !self[[7, 4]].moved
    end
  end
  
  def rook_unmoved?(color, side)
    if color == "b" && side == :kingside
      self[[0,7]].class == Rook && !self[[0, 7]].moved
    elsif  color == "b" && side == :queenside
      self[[0,0]].class == Rook && !self[[0, 0]].moved
    elsif color == "w" && side == :kingside
      self[[7,7]].class == Rook && !self[[7, 7]].moved
    elsif  color == "w" && side == :queenside
      self[[7,0]].class == Rook && !self[[7, 0]].moved
    end
  end
  
  def pieces_in_way?(color, side)
    if color == "b" && side == :kingside
      places_to_check = [[0, 6],[0, 5]]
    elsif  color == "b" && side == :queenside
      places_to_check = [[0, 1], [0, 2], [0, 3]]
    elsif color == "w" && side == :kingside
      places_to_check = [[7, 6], [7,5]]
    elsif color == "w" && side == :queenside
      places_to_check = [[7, 1], [7, 2], [7, 3]]
    end
    
    !places_to_check.all? {|place| vacant?(place)}
  end
  
  def vacant?(place)
    p place
    self[place].class == NilClass
  end
  
  
  
  # def over_check?(color, side)
#   end
    
end
