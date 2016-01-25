class Card
  attr_reader :rank, :suit

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def to_s
    "#{@rank.to_s.capitalize} of #{@suit.to_s.capitalize}"
  end

  def ==(other)
    to_s == other.to_s
  end

  def <(other)
    ranks = {jack: 11, queen: 12, king: 13, ace: 14}
    suits = {clubs: 1, diamonds: 2, hearts: 3, spades: 4}

    if suits[suit] < suits[other.suit]
      true
    elsif suits[suit] > suits[other.suit]
      false
    else
      ranks.fetch(rank, rank) < ranks.fetch(other.rank, other.rank)
    end
  end

  def >(other)
    not (self < other or self == other)
  end

  def <=>(other)
    return 0 if self == other
    return -1 if self < other
    return 1 if self > other
  end
end

class Deal
  def initialize(deal)
    @deal = deal
  end

  def size
    @deal.size
  end
end

class Deck
  include Enumerable

  def initialize(deck = Array.new)
    @deck = deck
    if @deck.empty?
      ranks = [:ace, :king, :queen, :jack] + (2..10).to_a.reverse
      generate_deck(ranks)
    end
  end

  def each
    @deck.each { |card| yield card }
  end

  def size
    @deck.size
  end

  def draw_top_card
    @deck.shift
  end

  def draw_bottom_card
    @deck.pop
  end

  def top_card
    @deck.first
  end

  def bottom_card
    @deck.last
  end

  def shuffle
    @deck.shuffle!
    self
  end

  def to_s
    string_deck = Array.new
    @deck.each { |card| string_deck << card.to_s }
    string_deck
  end

  def sort
    @deck.sort! { |current, following| following <=> current }
    self
  end

  def deal
    Deal.new(@deck)
  end

  private

  def generate_deck(ranks)
    suits = [:spades, :hearts, :diamonds, :clubs]

    suits.each do |suit|
      ranks.each { |rank| @deck << Card.new(rank, suit) }
    end
  end
end

class WarDeal < Deal
  def play_card
    play_card = @deal.sample
    @deal.delete_if { |card| card == play_card }
  end

  def allow_face_up?
    size <= 3
  end
end

class WarDeck < Deck
  def deal
    WarDeal.new(@deck.shift(26))
  end
end

class BeloteDeal < Deal
  def initialize(deal)
    super(deal)
    @ranks = {:jack => 10, :queen => 11, :king => 12, 10 => 13, :ace => 14}
  end

  def highest_of_suit(suit)
    cards_of_suit = @deal.select { |card| card.suit == suit }
    cards_of_suit.sort_by { |card| @ranks.fetch(card.rank, card.rank) }.last
  end

  def belote?
    cards = @deal.select { |card| card.rank == :queen or card.rank == :king}
    return true if cards.select { |card| card.suit == :clubs }.size == 2
    return true if cards.select { |card| card.suit == :diamonds }.size == 2
    return true if cards.select { |card| card.suit == :hearts }.size == 2
    return true if cards.select { |card| card.suit == :spades }.size == 2
    false
  end

  def tierce?
    @deal.sort_by! { |card| [card.suit, @ranks.fetch(card.rank, card.rank)] }
    suits = @deal.group_by(&:suit)
    suits.each_value { |suit| return true if find_consecutive(suit, 3)}
    false
  end

  def quarte?
    @deal.sort_by! { |card| [card.suit, @ranks.fetch(card.rank, card.rank)] }
    suits = @deal.group_by(&:suit)
    suits.each_value { |suit| return true if find_consecutive(suit, 4)}
    false
  end

  def quint?
    @deal.sort_by! { |card| [card.suit, @ranks.fetch(card.rank, card.rank)] }
    suits = @deal.group_by(&:suit)
    suits.each_value { |suit| return true if find_consecutive(suit, 5)}
    false
  end

  def carre_of_jacks?
    carre?(:jack)
  end

  def carre_of_nines?
    carre?(9)
  end

  def carre_of_aces?
    carre?(:ace)
  end

  private

  def carre?(rank)
    @deal.select { |card| card.rank == rank }.size == 4
  end

  def find_consecutive(cards, number)
    correct = 0
    ranks = cards.map { |card| @ranks.fetch(card.rank, card.rank) }
    expected = ranks.first
    ranks.each do |rank|
      expected == rank ? correct += 1 : break
      expected = expected.next
    end
    correct == number
  end
end

class BeloteDeck < Deck
  def initialize(deck = Array.new)
    @deck = deck
    if(@deck.empty?)
      ranks = [:ace, 10, :king, :queen, :jack, 9, 8, 7]
      generate_deck(ranks)
    end
  end

  def sort
    ranks = {:jack => 10, :queen => 11, :king => 12, 10 => 13, :ace => 14}

    @deck.sort_by! { |card| [card.suit, ranks.fetch(card.rank, card.rank)] }
    @deck.reverse!
  end

  def deal
    BeloteDeal.new(@deck.shift(8))
  end
end

class SixtySixDeal < Deal
  def twenty?(trump_suit)
    suits = @deal.group_by(&:suit)
    suits.delete(trump_suit)
    suits.each_value do |cards|
      queen = cards.any? { |card| card.rank == :queen }
      king = cards.any? { |card| card.rank == :king }

      return true if queen and king
    end
    false
  end

  def forty?(trump_suit)
    suits = @deal.group_by(&:suit)
    suits.each do |suit, cards|
      queen = cards.any? { |card| card.rank == :queen }
      king = cards.any? { |card| card.rank == :king }

      return true if (queen and king) and trump_suit == suit
    end
    false
  end
end

class SixtySixDeck < BeloteDeck
  def initialize(deck = Array.new)
    @deck = deck
    if(@deck.empty?)
      ranks = [:ace, 10, :king, :queen, :jack, 9]
      generate_deck(ranks)
    end
  end

  def deal
    SixtySixDeal.new(@deck.shift(6))
  end
end
