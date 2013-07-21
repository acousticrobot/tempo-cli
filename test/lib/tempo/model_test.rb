require "test_helper"
require "pry"

module Tempo
  class Animal < Tempo::Model
    attr_accessor :genious, :species

    def initialize( params={} )
      super params
      @genious = params[:genious]
      @species = params.fetch(:species, @genious)
    end
  end
end

describe Tempo do
  describe "Model" do

    gray_tree_frog = Tempo::Animal.new( { genious: "hyla", species: "h. versicolor" } )

    copes_gray_tree_frog = Tempo::Animal.new( { genious: "hyla", species: "h. chrysoscelis"})

    pine_barrens_tree_frog = Tempo::Animal.new( { genious: "hyla", species: "h. andersonii", id: 4 } )

    bird_voiced_tree_frog = Tempo::Animal.new( { genious: "hyla", species: "h. avivoca"} )

    chinese_tree_frog = Tempo::Animal.new( { genious: "hyla", species: "h. chinensis"} )

    it "should be a easy to inherit from" do
      Tempo::Animal.superclass.must_equal Tempo::Model
    end

    it "should allow child objects to freeze-dry" do
      frozen = gray_tree_frog.freeze_dry
      frozen.must_equal( {:id=>1, :genious=>"hyla", :species=>"h. versicolor"} )
    end

    it "should give id as a readable attribute" do
      gray_tree_frog.id.must_equal 1
      copes_gray_tree_frog.id.must_equal 2
    end

    it "should manage uniqe ids" do
      copes_gray_tree_frog.id.must_equal 2
    end

    it "should handle ids assigned and out of order" do
      Tempo::Animal.ids.must_equal [1,2,3,4,5]
      pine_barrens_tree_frog.id.must_equal 4
      bird_voiced_tree_frog.id.must_equal 3
      chinese_tree_frog.id.must_equal 5
    end

    it "should raise an error on duplicate id" do
      args = {  genious: "hyla",
                species: "h. flatulus",
                id: 1
              }
      proc { gassy_tree_frog = Tempo::Animal.new( args ) }.must_raise Tempo::IdentityConflictError
    end
  end
end