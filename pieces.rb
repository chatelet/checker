class Piece
  attr_reader :board, :color, :promote
  attr_accessor :pos

  MOVE_SLIDE_UP = [[-1, -1],[-1, 1]]
  MOVE_SLIDE_DOWN = [[1, -1], [1, 1]]
  MOVE_JUMP_UP = [[-2, -2], [-2, 2]]
  MOVE_JUMP_DOWN = [[2, -2], [2, 2]]

  def initialize(board, color, pos)
    @board = board
    @color = color
    @pos = pos
    @promote = false
  end

  def maybe_promote
    return if @promote
    case color
    when :black
      @promote = true if pos[0] == 7
    when :white
      @promote = true if pos[0] == 0
    end
  end

  def valid_pos?(pos)
    return true if pos[0].between?(0, 7) && pos[1].between?(0, 7)
    #raise "not a valid the move"
  end

  def perform_slide(dest_pos)
    slide_pos_arr = []
    slide_pos_arr = possible_slide_moves

    return false if slide_pos_arr.empty? || !slide_pos_arr.include?(dest_pos)
    @board[dest_pos] = self
    @board[pos] = nil
    self.pos = dest_pos.dup
    maybe_promote
    #self.board = @board

    true
  end

  def possible_slide_moves
    result = []
    # black moves down, white moves up except promoted
    move_slide_arr = (@color == :black ? MOVE_SLIDE_DOWN : MOVE_SLIDE_UP)
    if @promote
      move_slide_arr.concat(@color == :black ? MOVE_SLIDE_UP : MOVE_SLIDE_DOWN)
    end

    move_slide_arr.each do |dir|
      dx = pos[0] + dir[0]
      dy = pos[1] + dir[1]

      if valid_pos?([dx, dy])
        result << [dx, dy] if @board[[dx, dy]].nil? && !result.include?([dx,dy])
      end
    end
p "possible slide moves #{result}"
    result
  end


  def perform_jump(dest_pos)
    jump_pos_arr = []
    jump_pos_arr = possible_jump_moves

    return false if jump_pos_arr.empty? || !jump_pos_arr.include?(dest_pos)

    #update board, move current node, remove killed node
    new_dx = self.pos[0] + (dest_pos[0] - self.pos[0]) / 2
    new_dy = self.pos[1] + (dest_pos[1] - self.pos[1]) / 2

    @board[[new_dx, new_dy]] = nil
    @board[pos] = nil
    @board[dest_pos] = self
    self.pos = dest_pos.dup
    maybe_promote
    true
  end

  def possible_jump_moves
    result = []
    move_slide_arr = (@color == :black ? MOVE_SLIDE_DOWN : MOVE_SLIDE_UP)
    move_jump_arr = (@color == :black ? MOVE_JUMP_DOWN : MOVE_JUMP_UP)

    if @promote
      move_slide_arr.concat(@color == :black ? MOVE_SLIDE_UP : MOVE_SLIDE_DOWN)
      move_jump_arr.concat(@color == :black ? MOVE_JUMP_UP : MOVE_JUMP_DOWN)

    end

# p "pos #{pos}"
# p "move_slide_arr #{move_slide_arr}"

    move_slide_arr.each_index do |i|
      slide_x = pos[0] + move_slide_arr[i][0]
      slide_y = pos[1] + move_slide_arr[i][1]

      if valid_pos?([slide_x, slide_y])
        slide_piece = @board[[slide_x, slide_y]]
        if slide_piece && slide_piece.color != color
          # there is an opponent piece around
          # go next node in the same line to check whether it is nil
          # pos, slide_piece is opponent, [slide_x, slide_y]
          jump_x = slide_x + (slide_x - pos[0])
          jump_y = slide_y + (slide_y - pos[1])
          if valid_pos?([jump_x, jump_y])
            if @board[[jump_x, jump_y]].nil?
              #the next piece followed by jump piece is nil
              result << [jump_x, jump_y] unless result.include?([jump_x, jump_y])
            end # else can't perform jump
          end #else a pos in board

        end #else can't perform jump
      end #else not a pos in board
    end
p "possible jump moves #{result}"
    result
  end

  def perform_moves!(move_sequence)
    num = move_sequence.count
    case num
    when 0
      return
    when 1
    end
  end


end
