require_relative 'pieces.rb'
#handle invalided user input


class Board
  attr_reader :grid
  def initialize(fill_board = true)
    make_starting_board(fill_board)
  end

  def [](pos)
    i, j = pos
    grid[i][j]
  end

  def []=(pos, value)
    i, j = pos
    grid[i][j] = value
  end

  def pieces
    @grid.flatten.compact
  end

  def display
    puts " 0123456789"
    puts " ----------"
    count = 0
    @grid.each do |row|
      str = count.to_s
      row.each do |el|
        if el
          if el.color == :black
            str += 'B'
          else
            str += 'W'
          end
        else
          str += '_'
        end
      end
      puts str

      count += 1
    end
    puts " ----------"
    puts " 0123456789"
  end

  def play
    flag = 'w'
    loop do
      #check if there is piece in current player that can perform a jump
      if flag == 'w'
        piece_same_color = pieces.select{|el| el.color == :white}
        p "white's turn"
        flag = 'b'
      else
        piece_same_color = pieces.select{|el| el.color == :black}
        p "black's turn"
        flag = 'w'
      end

      jump_flag = false
      piece_same_color.each do |el|
        tmp_jump_arr = el.possible_jump_moves
        pos_start = el.pos.dup
        if !tmp_jump_arr.empty?
          p "there is a jump existed for piece #{el.pos}, run the jump"
          jump_flag = true
          pos_dest = tmp_jump_arr.sample
          self[pos_start].perform_jump(pos_dest)
          display

          jumps_arr = self[pos_dest].possible_jump_moves
          until jumps_arr.empty?
            p "have to do a jump not a slide, choose one available jumps from below "
            p jumps_arr

            input = gets.chomp
            new_pos_dest = []
            input.split(',').each do |i|
              new_pos_dest << Integer(i)
            end
            self[pos_dest].perform_jump(new_pos_dest)
            display
            pos_dest = new_pos_dest.dup

            jumps_arr = self[pos_dest].possible_jump_moves
          end
          break
        end
      end

      next if jump_flag
      
      puts "choose a piece 9,9"
      input = gets.chomp
      pos_start = []
      input.split(',').each do |i|
        pos_start << Integer(i)
      end

break if pos_start == [10, 10]

      puts "choose a destination 0, 0"
      input = gets.chomp
      pos_dest = []
      input.split(',').each do |i|
        pos_dest << Integer(i)
      end

      # keep jumping if there is a chance
      if jump_move?(pos_start, pos_dest)
        self[pos_start].perform_jump(pos_dest)
        display
        p "jump"
      else
        if slide_move?(pos_start, pos_dest)
          self[pos_start].perform_slide(pos_dest)
          display
          p "slide"
        end
      end
    end
  end



      # if jump_move?(pos_start, pos_dest)
      #   p "have to do a jump not a slide, available jumps are "
      #   self[pos_start].perform_jump(pos_dest)
      #   p "jump"
      # else
      #   if slide_move?(pos_start, pos_dest)
      #     self[pos_start].perform_slide(pos_dest)
      #     p "slide"
      #   end
      # end


  def slide_move?(pos_start, pos_dest)
    tmp = self[pos_start].possible_slide_moves
    #true if self[pos_start].possible_slide_moves.include?(pos_dest)
    p tmp.include?(pos_dest)
    return true if tmp.include?(pos_dest)
    false
  end

  def jump_move?(pos_start, pos_dest)
    return true if self[pos_start].possible_jump_moves.include?(pos_dest)
    false
  end

  private
  def fill_board_with_piece
    (0..3).each do |i|
      if i % 2 == 0
        (0..4).each do |j|
          self[[i, j * 2 + 1]] = Piece.new(self, :black, [i, j * 2 + 1])
        end
      else
        (0..4).each do |j|
          self[[i, j * 2]] = Piece.new(self, :black, [i, j * 2])
        end
      end
    end

    (6..9).each do |i|
      if i % 2 == 0
        (0..4).each do |j|
          self[[i, j * 2 + 1]] = Piece.new(self, :white, [i, j * 2 + 1])
        end
      else
        (0..4).each do |j|
          self[[i, j * 2]] = Piece.new(self, :white, [i, j * 2])
        end
      end
    end
  end

  def make_starting_board(fill)
    @grid = Array.new(10) {Array.new(10)}
    return unless fill
    fill_board_with_piece
  end
end

if $PROGRAM_NAME == __FILE__
  b = Board.new
  b.display
  b.play
end
