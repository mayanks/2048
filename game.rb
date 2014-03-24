require 'io/console'
require 'colorize'
 
UP = 0
DOWN = 1
LEFT = 2
RIGHT = 3
directions_map = ['UP','DOWN','LEFT','RIGHT']

# Reads keypresses from the user including 2 and 3 escape character sequences.
def read_char
  STDIN.echo = false
  STDIN.raw!
 
  input = STDIN.getc.chr
  if input == "\e" then
    input << STDIN.read_nonblock(3) rescue nil
    input << STDIN.read_nonblock(2) rescue nil
  end
ensure
  STDIN.echo = true
  STDIN.cooked!
 
  return input
end

def get_dir
  _dir = nil
  while(_dir.nil?)
    c = read_char()

    case c
    when "\e[A"
      _dir = UP
    when "\e[B"
      _dir = DOWN
    when "\e[C"
      _dir = RIGHT
    when "\e[D"
      _dir = LEFT
    when "\u0003"
      puts "Exiting..."
      exit 0
    end
  end
  return _dir
end

class Game
  #{ :black => 0, :red => 1, :green => 2, :yellow => 3, :blue => 4, :magenta => 5, :cyan => 6, :white => 7, :default => 9, :light_black => 10, :light_red => 11, :light_green => 12, :light_yellow => 13, :light_blue => 14, :light_magenta => 15, :light_cyan => 16, :light_white => 17}
  COLOR_CODE = {
      0 => :black, 
      2 => :light_white, 
      4 => :yellow, 
      8 => :light_cyan, 
      16 => :cyan, 
      32 => :light_green, 
      64 => :green, 
      128 => :light_magenta, 
      256 => :magenta, 
      512 => :light_red, 
      1024 => :red, 
      2048 => :light_blue, 
      4096 => :light_white 
    }

  SIZE = 4

  def initialize
    @matrix = 0.upto(SIZE-1).map {|a| Array.new(SIZE,0)}
    self.insert_2
    self.insert_2
  end

  def pretty_print
    0.upto(SIZE-1) do |i|
      puts @matrix[i].map{|a| format("%4d",a).colorize(COLOR_CODE[a])}.join(' ')
    end
  end

  def reduce(new_arr)
    new_arr.delete(0)
    new_arr.each_index do |i|
      next if i == 0
      if new_arr[i] == new_arr[i-1]
        new_arr[i-1] *= 2
        new_arr[i] = 0
      end
    end
    new_arr.delete(0)

    _ret = Array.new(SIZE,0)
    new_arr.each_index {|i| _ret[i] = new_arr[i]}
    return _ret
  end

  def empty_tiles
    if @empty_tiles.nil?
      @empty_tiles = 0
      0.upto(SIZE-1) {|i| 0.upto(SIZE-1) { |j| @empty_tiles += 1 if @matrix[i][j] == 0 } }
    end
    return @empty_tiles
  end

  def insert_2
    @empty_tiles = nil
    if self.empty_tiles > 0
      k = rand(self.empty_tiles).to_i
      0.upto(SIZE-1) do |i| 
        0.upto(SIZE-1) do |j| 
          if @matrix[i][j] == 0 
            if k == 0
              @matrix[i][j] = 2 if k == 0
              return
            end
            k -= 1
          end
        end
      end
    end
  end
 
  def move(dir)
    _ret = false
    0.upto(SIZE-1) do |i|
      arr = 0.upto(SIZE-1).map do |j| 
        if dir == UP
          @matrix[j][i]
        elsif (dir == DOWN)
          @matrix[SIZE-1-j][i]
        elsif (dir == LEFT)
          @matrix[i][j]
        elsif (dir == RIGHT)
          @matrix[i][SIZE-1-j]
        end
      end

      new_arr = reduce(arr.clone)
      if arr == new_arr
        _ret = _ret or false
      else
        _ret = true
        new_arr.each_index do |j| 
          if dir == UP
            @matrix[j][i] = new_arr[j] 
          elsif dir == DOWN
            @matrix[SIZE-1-j][i] = new_arr[j] 
          elsif dir == LEFT
            @matrix[i][j] = new_arr[j] 
          elsif dir == RIGHT
            @matrix[i][SIZE-1-j] = new_arr[j] 
          end
        end
      end
    end

    if _ret 
      self.insert_2
    end

    return _ret
  end
end

game = Game.new
game.pretty_print

while(true)
  _dir = get_dir
  if game.move(_dir)
    puts "----- #{directions_map[_dir]} -------"
    game.pretty_print
    puts
  end
end


