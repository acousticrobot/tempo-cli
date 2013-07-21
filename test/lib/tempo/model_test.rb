require "test_helper"
require "pry"

module Tempo
  class Animal < Tempo::Model
    attr_accessor :genious, :species

    def initialize( params={} )
      super
      @genious = params[:genious]
      @species = params.fetch(:species, @genious)
    end
  end
end

describe Tempo do
  describe "Model" do

    gray_tree_frog = Tempo::Animal.new( { genious: "hayla", species: "h. versicolor" } )

    it "should be a easy to inherit from" do
      Tempo::Animal.superclass.must_equal Tempo::Model
    end

    it "should allow child objects to freeze-dry" do
      frozen = gray_tree_frog.freeze_dry
      frozen.must_equal( {:id=>1, :genious=>"hayla", :species=>"h. versicolor"} )
    end

    it "should give id as a readable attribute" do
      gray_tree_frog.id.must_equal 1
    end
  end
end