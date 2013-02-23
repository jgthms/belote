#short defines
def card_long(suit, rank)
  Card.new suit, rank
end

def card(short)
  Card.make_card_short(short)
end

def hand_long(*cards)
  Hand.new *cards
end

def hand(*cards)
  Hand.new cards.map(&:card)
end

def cards_arr(*strs)
  strs.map { |short| send(:card, short) }
end

def test_function(func, data)
  data.each do |*args, result|
    #begin
      func.call(*args).should eq(result), "test arguments #{args} expected #{result}"
    #rescue
     # raise "exception when testing with test arguments #{args} expected #{result}"
    #end
  end
end