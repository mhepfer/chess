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
      move_directions = move_dirs.map { |offset| [offset.first * -1, offset.last] }
      attack_directions = attack_dirs.map{ |offset| [offset.first * -1, offset.last] }
      at_home = @position[0] == 6
    else
      move_directions = move_dirs
      attack_directions = attack_dirs
      at_home = @position[0] == 1
    end
    
    offset_array << move_directions.first unless occupied?(update_position(@position, move_directions.first))
    if at_home
      offset_array << move_directions.last unless occupied?(update_position(@position, move_directions.last))
    end
    
    attack_directions.each do |offset|      
      possible_space = update_position(@position, offset)
      offset_array << offset if occupied_by_enemy?(possible_space)
    end
    
    offset_array.map{|offset| update_position(@position, offset)}
  end
  
  def to_s
    @color == "w" ? "\u2659" : "\u265F"
  end
  
  def occupied_by_enemy?(position)
    occupied?(position) && @board[position].color != self.color
  end
  
end