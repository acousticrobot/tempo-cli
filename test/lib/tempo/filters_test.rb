require "test_helper"

describe Tempo do
  describe "Filters" do
    describe "fuzzy match" do

      describe "matching an array" do

        haystack = ['sheep','ducks','peeping-ducks','sheep ducks']
        match = 'ducks'
        matches = ['ducks', 'eep']

        it "should find all matches to a single match object" do
          Tempo::fuzzy_match( haystack, match ).must_equal ['ducks','peeping-ducks','sheep ducks']
        end

        it "should find all matches to an array of match objects" do
          Tempo::fuzzy_match( haystack, matches ).must_equal ['peeping-ducks','sheep ducks']
        end
      end

      describe "matching a Tempo Model" do
        it "should find all matches to a single match object" do
          pantherinae_factory
          matches = Tempo::fuzzy_match( Tempo::Model::Animal, "Panthera", "genious" )
          matches.length.must_equal 5
        end

        it "should find all matches to an array of match objects" do
          pantherinae_factory
          matches = Tempo::fuzzy_match( Tempo::Model::Animal, ["p. ", "a"], "species" )
          # "p. onca", "p. pardus" "p. zdanskyi"
          matches.length.must_equal 3
        end
      end
    end

    describe "reassemble to args" do

      it "should reassemble the args passed in as an array" do
        test_args = ["an", "array", "of", "args"]
        test_flag = "I'm"
        Tempo::reassemble_the( test_args ).must_equal "an array of args"
      end

      it "should reassemble the args with a flag in the front" do
        test_args = ["an", "array", "of", "args"]
        test_flag = "I'm"
        Tempo::reassemble_the( test_args, test_flag ).must_equal "I'm an array of args"
      end
    end
  end
end