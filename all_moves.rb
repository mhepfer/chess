def moves
  start_x, start_y = start_pos
  max_radius = 11.313
  result = []
  current_degree = degree_increment
  while current_degree <= 2.0*(Math::PI)
    current_radius = radius_from_piece

      while max_radius >= current_radius #&& we haven't hit something'
        unless (current_degree % mod_degree) == 0
          y = start_y + current_radius * Math.sin(current_degree.to_f)
          x = start_x + current_radius * Math.cos(current_degree.to_f)
          result << [x.round, y.round]
        end
        current_radius += radius_from_piece
      end

    current_degree += degree_increment
  end
  result.select!{|pos| pos.first.between?(0, 7) && pos.last.between?(0, 7)}
  p result.length
  result
end

#bishop degree_increment = Math::PI/4, radius_from_piece = Math::sqrt(2), mod_degree = Math::PI/2, start_pos

# DEGREE_INCREMENT = Math::PI/4
#
# RADIUS_FROM_PIECE = Math::sqrt(2)
#
# MAX_RADIUS = Math::sqrt(98)
#
# MOD_DEGREE = Math::PI/2

# def initialize(board, position, color)
#   super(board, position, color, DEGREE_INCREMENT, RADIUS_FROM_PIECE, MAX_RADIUS, MOD_DEGREE)
# end