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

    def highest_of_suit(suit)
      cards_of_suit = @deal.select { |card| card.suit == suit }
      cards_of_suit.sort_by { |card| RANKS.find_index(card.rank) }.last
    end

    def belote?
      Deck::SUITS.any? do |suit|
        intersection = @deal & [Card.new(:king, suit), Card.new(:queen, suit)]
        intersection.size == 2
      end
    end

    def tierce?
      find_consecutive(3)
    end

    def quarte?
      find_consecutive(4)
    end

    def quint?
      find_consecutive(5)
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

    def find_consecutive(number)
      cards = @deal.sort_by { |card| RANKS.find_index(card.rank) }
      Deck::SUITS.any? do |suit|
        cards.select { |card| card.suit == suit }.
          each_cons(number).
          any? { |piece| consecutive_ranks?(piece) }
      end
    end

    def consecutive_ranks?(cards)
      cards.each_cons(2).all? do |first, second|
        RANKS.index(first.rank) == RANKS.index(second.rank) - 1
      end
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
      has_queen_and_king?(Deck::SUITS - [trump_suit])
    end

    def forty?(trump_suit)
      has_queen_and_king?(trump_suit)
    end

    private

    def has_queen_and_king?(suits)
      suits.any? do |suit|
        intersection = @deal & [Card.new(:king, suit), Card.new(:queen, suit)]
        intersection.size == 2
      end
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
