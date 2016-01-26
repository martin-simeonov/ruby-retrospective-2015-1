class Integer
  def prime?
    return false if self == 1
    (2..self**0.5).each { |number| return false if (self % number) == 0 }
    true
  end
end

class RationalSequence
  include Enumerable

  def initialize(limit = 0)
    @limit = limit
  end

  def each(&block)
    enum_for(:generate_rationals).
      lazy.
      select { |numerator, denominator| numerator.gcd(denominator) == 1 }.
      map { |numerator, denominator| Rational(numerator, denominator) }.
      take(@limit).
      each(&block)
  end

  private

  def generate_rationals
    numerator = denominator = 1
    loop do
      yield [numerator, denominator]
      numerator, denominator = next_rational(numerator, denominator)
    end
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
end

class PrimeSequence
  include Enumerable

  def initialize(limit = 0)
    @limit = limit
  end

  def each(&block)
    (1..Float::INFINITY).to_enum.
      lazy.
      select { |number| number.prime? }.
      take(@limit).
      each(&block)
  end
end

class FibonacciSequence
  include Enumerable

  def initialize(limit = 0, first: 1, second: 1)
    @limit = limit
    @first = first
    @second = second
  end

  def each(&block)
    enum_for(:generate_fibonacci_numbers).
      lazy.
      take(@limit).
      each(&block)
  end

  private

  def generate_fibonacci_numbers
    previous = @first
    current = @second

    loop do
      yield previous
      current, previous = current + previous, current
    end
  end
end

module DrunkenMathematician
  module_function

  def meaningless(n)
    sequence = RationalSequence.new(n)
    prime, non_prime = sequence.partition { |n| n.numerator.prime? or n.denominator.prime? }
    prime.reduce(1, :*) / non_prime.reduce(1, :*)
  end

  def aimless(n)
    sequence = PrimeSequence.new(n)
    sequence.each_slice(2).map { |a, b| Rational(a, (b or 1)) }.reduce(0, :+)
  end

  def worthless(n)
    fibonacci_limit = FibonacciSequence.new(n).to_a.last
    fibonacci_limit ||= 0

    sum = 0

    RationalSequence.new(fibonacci_limit**2).take_while do |n|
      sum += n
      sum <= fibonacci_limit
    end
  end
end
