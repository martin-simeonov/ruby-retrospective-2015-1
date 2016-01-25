class Integer
  def prime?
    return false if self == 1
    (2..self/2).each { |number| return false if (self % number) == 0 }
    true
  end
end

class RationalSequence
  include Enumerable

  def initialize(limit = 0)
    @limit = limit
  end

  def next_rational(numerator, denominator)
    if numerator % 2 == denominator % 2
       numerator += 1
       denominator -= 1 if denominator > 1
    else
       denominator += 1
       numerator -= 1 if numerator > 1
    end
    [numerator, denominator]
  end

  def each
    numerator = denominator = 1
    count = 0

    while count < @limit
      if numerator.gcd(denominator) == 1
        yield Rational(numerator, denominator)
        count += 1
      end
      numerator, denominator = next_rational(numerator, denominator)
    end
  end
end

class PrimeSequence
  include Enumerable

  def initialize(limit = 0)
    @limit = limit
  end

  def each
    number = 2
    count = 0

    while count < @limit
      if number.prime?
        yield number
        count += 1
      end
      number += 1
    end
  end
end

class FibonacciSequence
  include Enumerable

  def initialize(limit = 0, first: 1, second: 1)
    @limit = limit
    @first = first
    @second = second
  end

  def each
    previous = @first
    current = @second
    count = 0

    while count < @limit
      yield previous
      count += 1
      current, previous = current + previous, current
    end
  end
end

module DrunkenMathematician
  module_function

  def meaningless(n)
    sequence = RationalSequence.new(n)
    first_group = sequence.select { |n| n.numerator.prime? or n.denominator.prime? }
    second_group = sequence.to_a - first_group
    first_group.reduce(1, :*) / second_group.reduce(1, :*)
  end

  def aimless(n)
    sequence = PrimeSequence.new(n)
    pairs = Array.new
    sequence.each_slice(2) { |slice| pairs << Rational(slice[0], (slice[1] or 1)) }
    pairs.reduce(0, :+)
  end

  def worthless(n)
    fibonacci_limit = FibonacciSequence.new(n).to_a.last
    fibonacci_limit ||= 0
    sequence = RationalSequence.new(Float::INFINITY)
    sum = 0
    sequence.take_while do |n|
      sum += n
      sum <= fibonacci_limit
    end
  end
end
