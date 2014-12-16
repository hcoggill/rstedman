
module Stedman

class MusicGen

  def initialize(num_bells, rows)
    @n = num_bells
    @rows = rows
  end

  def named_changes
    music = { Backrounds: [[backrounds, HAND + BACK]], Queens: [[queens, HAND + BACK]], Kings: [[kings, HAND + BACK]], Tittums: [[tittums, HAND + BACK]], Nearmiss: nearmisses, DoubleWhittingtons: [[doublewhittingtons, HAND + BACK]], Updown: [[updown, HAND + BACK]], HandstrokeHomes: [[homes, HAND]], BackstrokeHomes: [[homes, BACK]] }
  end

  def nearmisses
    miss_list = []
    rounds = Array(1..@n)
    (@n - 1).times do |i|
      miss_list << [swap_pair(rounds, i), HAND + BACK]
    end
    miss_list
  end

  def swap_pair(ary, offset)
    swapped = Array.new(ary)
    a = swapped[offset]
    b = swapped[offset + 1]
    swapped[offset] = b
    swapped[offset + 1] = a
    return swapped
  end

  def homes
    Array[nil] * (@n / 2.0).ceil + Array(((@n / 2.0).ceil + 1)..@n)    
  end

  def updown
    Array(1..(@n / 2.0).ceil).reverse + Array(((@n / 2.0).ceil + 1)..@n)
  end

  def backrounds
    Array(1..@n).reverse
  end

  def queens
    Array((1..@n).step(2)) + Array((2..@n).step(2))
  end

  def kings
    Array((1..@n).step(2)).reverse + Array((2..@n).step(2))
  end

  def tittums
    Array(1..(@n / 2.0).ceil).zip(Array(((@n / 2.0).ceil + 1)..@n)).flatten.compact
  end

  def doublewhittingtons
    m = (@n / 2.0).ceil
    Array((1..m).step(2)).reverse + Array((2..m).step(2)) + Array(((m + 1)..@n).step(2)).reverse + Array(((m + 2)..@n).step(2))
  end

  def check_music
    music = named_changes
    stroke = HAND   # FIXME
    @rows.each do |row|
      parse_music_row(music, row, stroke)
      stroke = (stroke % 2) + 1
    end
  end

  def parse_music_row(music, row, stroke)
    music.each do |name, requirements|
      requirements.each do |mus|
        next if mus.last != HAND + BACK and mus.last != stroke
        if comp_music_row(mus.first, row)
          @musicals[name] ||= 0 and @musicals[name] += 1
        end
      end
    end
  end

  def comp_music_row(a, b)
    return false unless a.length == b.length
    a.length.times do |i|
      return false if not a[i].nil? and not a[i] == b[i]
    end
    true
  end



end

