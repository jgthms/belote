require 'set'
require_relative 'short_defines'

describe 'Announces' do
  include_context "Tests Helper"

  let(:announce) do   # FIXME: module now extends itself
    Class.new { include Announces }.new
  end

  it 'finds sequences of same suit' do
    [
      [%w[c8 s8 c10 cj ha c7 c9 sj], %w[c8 c10 cj c7 c9]],
      [%w[hj da c8 sk sq s10 sj cj], %w[sk sq s10 sj]],
      [%w[h10 hj d9 hq d10 h9 c7 h8], %w[h10 hj hq h9 h8]],
      [%w[h10 dj d9 hq d10 h9 s7 d8], %w[dj d9 d10]],
      [%w[h10 dj d9 hq d10 h9 s7 d8], %w[dj d9 d10 d8]],
    ].each do |test, result|
      announce.sequence(hand(to_cards(test)), result.size).should eq to_cards(result)
    end

    # no announces
    [
      %w[h10 sj d9 hq d10 h9 d7 dk],
      %w[s9 h8 d10 hq ca c7 d8 s10],
    ].each do |test|
      (3..5).each do |length|
        announce.sequence(hand(to_cards(test)), length).should eq []
      end
    end
  end

  it 'finds all sequences of given length and same suit' do
    [
      [%w[h10 hj d9 hq d10 h9 c7 h8], 5, [%w[h10 hj hq h9 h8]]],
      [%w[sa sk sq sj da dk dq dj], 4, [%w[sa sk sq sj], %w[da dk dq dj]]],
      [%w[da dk dq d10 d9 d8 ha hk hq], 3, [%w[ha hk hq], %w[da dk dq], %w[d10 d9 d8]]],
    ].each do |tests, seq_len, result|
      tests = hand(to_cards(tests))
      result = result.map { |seq| to_cards(seq) }

      announce.find_all_sequences(tests, seq_len).should eq result
    end
  end

  it 'finds quintas' do
    [
      [%w[c8 s8 c10 cj ha c7 c9 sj], %w[c8 c10 cj c7 c9]],
      [%w[hj sa c8 sk sq s10 sj cj], %w[sa sk sq s10 sj]],
      [%w[h10 hj d9 hq d10 h9 c7 h8], %w[h10 hj hq h9 h8]],
      [%w[h10 dj d9 hq d10 h9 d7 d8], %w[dj d9 d10 d7 d8]],
    ].each do |test, result|
      test = hand(to_cards(test))
      result = [:quinta, to_cards(result)]

      announce.find_quinta(test).should eq result
    end

    # no quintas
    [
      %w[h10 hj d9 hq d10 h9 d7 d8],
      %w[s9 h8 d10 hq ca c7 d8 s10],
    ].each do |test|
      announce.find_quinta(hand(to_cards(test))).should eq []
    end
  end

  it 'finds quartas' do
    [
      [%w[c8 s8 c10 dj ha c7 c9 sj], %w[c8 c10 c7 c9]],
      [%w[hj sa c8 sk sq sj dj cj], %w[sa sk sq sj]],
      [%w[h10 hj d9 hq d10 h9 c7 s8], %w[h10 hj hq h9]],
      [%w[h10 dj d9 hq d10 h9 s7 d8], %w[dj d9 d10 d8]],
      [%w[sa sk sq sj da dk dq dj], %w[sa sk sq sj], %w[da dk dq dj]],
    ].each do |test, *result|
      test = hand(to_cards(test))
      result = [:quarta, result.map { |seq| to_cards(seq) } ].flatten(1)  # REFACTOR check splat '*' on result array: *result.map ...

      announce.find_quarta(test).should eq result
    end

    # no quartas
    [
      %w[h10 cj d9 hq d10 h9 s7 d8],
      %w[s9 h8 d10 hq ca c7 d8 s10],
      %w[sa sk sq hj s10 s9 s8],
    ].each do |test|
      announce.find_quarta(hand(to_cards(test))).should eq []
    end
  end

  it 'finds thertas' do
    [
      [%w[sa sk sq ha h10 h9 cq c8], %w[sa sk sq]],
      [%w[c8 sk s9 h7 c7 d8 d10 c9], %w[c8 c7 c9]],
      [%w[hj ha hk h10 h7 h9 c9 d8], %w[hj h10 h9]],
      [%w[ca ck cq h8 h9 c10 c9 c8], %w[ca ck cq], %w[c10 c9 c8]],
    ].each do |test, *result|
      test = hand(to_cards(test))
      result = [:therta, result.map { |seq| to_cards(seq) } ].flatten(1) # REFACTOR splat

      announce.find_therta(test).should eq result
    end

    # no thertas
    [
      %w[h10 cj d9 hq ca h9 s7 d8],
      %w[s9 h8 d10 hq ca c7 d8 s10],
    ].each do |test|
      announce.find_therta(hand(to_cards(test))).should eq []
    end
  end

  it 'finds carres' do
    [
      [%w[sj dj hj cj s9 h9 d9 c9], [:carre, :jack, :r9]],
      [%w[h10 h9 s10 sa s7 c10 c8 d10], [:carre, :r10]],
    ].each do |test, result|
      announce.find_carre(hand(to_cards(test))).should eq result
    end

    test = hand(to_cards(%w[s7 h7 d7 c7 s8 h8 d8 c8]))
    announce.find_carre(test).should eq []
  end

  it 'finds belote' do
    [
      [%w[sq h9 s10 sj dj ck dq sk], [:belote, %w[sq sk]]],
      [%w[sq hk cq dk hq ck dq sk], [:belote, %w[sq sk], %w[hk hq], %w[dk dq], %w[cq ck]]],
    ].each do |test, result|
      result = [result[0], result.drop(1).map { |belote| to_cards(belote) } ].flatten(1)  # REFACTOR splat

      announce.find_belote(hand(to_cards(test))).should eq result
    end
  end

  it 'finds all announces' do
    [
      [
        %w[sa sk sq sj s10 hq hj h10],
        [
         [:belote, to_cards(%w[sk sq])],
         [:quinta, to_cards(%w[sa sk sq sj s10])],
         [:therta, to_cards(%w[hq hj h10])],
        ],
      ],
      [
        %w[s7 d7 s8 d10 s9 hk ha cj],
        [[:therta, to_cards(%w[s7 s8 s9])]]
      ],
      [
        %w[sa sk sq sj s10 d10 h10 c10],
        [
         [:belote, to_cards(%w[sk sq])],
         [:carre, :r10],
         [:quinta, to_cards(%w[sa sk sq sj s10])],
         ]
      ],
    ].each do |some_hand, result|
      announce.announces(hand(to_cards(some_hand))).should eq result
      # (Set.new annons).should eq Set.new result
    end
  end

  it 'evalueates announces' do
    [
      [[[:belote,]], 20],
      [[[:therta,]], 20],
      [[[:quarta,]], 50],
      [[[:quinta,]], 100],
      [[[:carre,]], 100],
      [[[:carre, :r9]], 150],
      [[[:carre, :jack]], 200],
      [[[:belote,], [:therta, [:ace,]], [:belote,]], 60],
      [[[:quinta, [:ace,]], [:quarta, [:ace,]], [:carre, :r10], [:therta, [:king,]]], 270],
    ].each do |arg, result|
      announce.evaluate(arg).should eq result
    end
  end
end

describe 'CompareAnnounces' do
  include_context "Tests Helper"

  it 'identify sequential announces' do
    CompareAnnounces.sequential_announce?(:therta).should be_true
    CompareAnnounces.sequential_announce?(:quarta).should be_true
    CompareAnnounces.sequential_announce?(:quinta).should be_true

    CompareAnnounces.sequential_announce?(:belote).should be_false
    CompareAnnounces.sequential_announce?(:carre).should be_false
  end

  it 'compares ranks' do
    [
      ['sk', 'sq',  1],
      ['sj', 'sa', -1],
      ['dk', 'dq', 1],
      ['cj', 'sa', -1],
      ['c7', 'dj', -1],
      ['d10', 'd9', 1],
      ['d7', 'h9', -1],
      ['d9', 'd10', -1],
    ].each do |card1, card2, result|
      CompareAnnounces.compare_ranks(card(card1), card(card2)).should eq(result),
        "test arguments #{card1} #{card2} expected #{result}"
    end
  end

  it 'tells max rank' do
    [
      [['sa'], :ace],
      [['hk'], :king],
      [['dq'], :queen],
      [['cj'], :jack],
      [['s10'], :r10],
      [['h9'], :r9],
      [['d8'], :r8],
      [['c7'], :r7],
    
      [%w[sq h9 s10 sj dj ck dq sk], :king],
      [%w[sq hk cq dk hq ck dq sk], :king],
      [%w[hj sa c8 sk sq sj dj cj], :ace],
    ].each do |cards, result|
      CompareAnnounces.max_rank(to_cards(cards)).should eq(result),
        "test arguments #{cards} expected #{result}"
    end
  end
  
  it 'compares sequences' do
    
  end
end
