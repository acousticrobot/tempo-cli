require "test_helper"

describe Tempo do
  describe "Filters" do
    describe "fuzzy match" do

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

    describe "reassemble to args" do

      test_args = ["an", "array", "of", "args"]
      test_flag = "I'm"

      it "should reassemble the args passed in as an array" do
        Tempo::reassemble_the( test_args ).must_equal "an array of args"
      end

      it "should reassemble the args with a flag in the front" do
        Tempo::reassemble_the( test_args, test_flag ).must_equal "I'm an array of args"
      end
    end
  end
end