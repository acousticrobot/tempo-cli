require "test_helper"

describe Tempo do
  describe "Filters" do

    haystack = ['sheep','ducks','peeping-ducks','sheep ducks']
    match = ['ducks']
    matches = ['ducks', 'eep']

    it "should find all matches to a single match object" do
      Tempo::fuzzy_match(haystack, match).must_equal ['ducks','peeping-ducks','sheep ducks']
    end

    it "should find all matches to a multiple match object" do
      Tempo::fuzzy_match(haystack, matches).must_equal ['peeping-ducks','sheep ducks']
    end

  end
end