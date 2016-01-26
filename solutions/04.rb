class Card < Struct.new(:rank, :suit)
  def to_s
    "#{rank.to_s.capitalize} of #{suit.to_s.capitalize}"
  end
end

class Deck
  class Deal
    INITIAL_SIZE = 26

    def initialize(deal)
      @deal = deal
    end

    def size
      @deal.size
    end
  end

  include Enumerable

  SUITS = [:clubs, :diamonds, :hearts, :spades]
  RANKS = [2, 3, 4, 5, 6, 7, 8, 9, 10, :jack, :queen, :king, :ace]

  def initialize(deck = Array.new, ranks = RANKS)
    @ranks = ranks
    @deck = deck
    if @deck.empty?
      @deck = SUITS.product(@ranks).map { |suit, rank| Card.new(rank, suit) }
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
    @deck.map(&:to_s).join("\n")
  end

  def sort
    @deck.sort_by! { |card| card_grade(card) }
    @deck.reverse!
  end

  def deal
    Deal.new(@deck)
  end

  private

  def card_grade(card)
    suit_grade = SUITS.find_index(card.suit)
    rank_grade = @ranks.find_index(card.rank)

    suit_grade * @ranks.size + rank_grade
  end

  def compare_cards(card_one, card_two)
    card_grade(card_one) <=> card_grade(card_two)
  end
end

class WarDeck < Deck
  class WarDeal < Deck::Deal
    def play_card
      play_card = @deal.sample
      @deal.delete_if { |card| card == play_card }
    end

    def allow_face_up?
      size <= 3
    end
  end

  def deal
    WarDeal.new(@deck.shift(WarDeal::INITIAL_SIZE))
  end
end

class BeloteDeck < Deck
  class BeloteDeal < Deck::Deal
    INITIAL_SIZE = 8

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
        if expected == rank
          correct += 1
        else
          correct = 0
          expected = expected.next
        end
        expected = expected.next
        return true if correct == number
      end
      false
    end
  end

  RANKS = [7, 8, 9, :jack, :queen, :king, 10, :ace]

  def initialize(deck = Array.new)
    super(deck, RANKS)
  end

  def deal
    BeloteDeal.new(@deck.shift(BeloteDeal::INITIAL_SIZE))
  end
end

class SixtySixDeck < Deck
  class SixtySixDeal < Deck::Deal
    INITIAL_SIZE = 6

    def twenty?(trump_suit)
      suits = Deck::SUITS - [trump_suit]
      suits.any? do |suit|
        intersection = @deal & [Card.new(:king, suit), Card.new(:queen, suit)])
        intersection.size == 2
      end
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

  RANKS = [9, :jack, :queen, :king, 10, :ace]

  def initialize(deck = Array.new)
    super(deck, RANKS)
  end

  def deal
    SixtySixDeal.new(@deck.shift(SixtySixDeal::INITIAL_SIZE))
  end
end
