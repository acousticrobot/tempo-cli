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

    def self.clear_all()
      @ids = []
      @index = []
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

    it "should grant child objects the freeze-dry method" do
      frozen = gray_tree_frog.freeze_dry
      frozen.must_equal( {:id=>1, :genious=>"hyla", :species=>"h. versicolor"} )
    end

    it "should grant child objects a self indexing method" do
      Tempo::Animal.index.length.must_equal 5
      Tempo::Animal.index.each do |animal|
        animal.id.must_be_kind_of(Integer)
        animal.genious.must_match "hyla"
        animal.species.must_match /^h\. \w./
      end
    end

    it "should create a file name to save to" do
      Tempo::Animal.file.must_equal "tempo_animals.yaml"
    end

    it "should grant children the ability to write to a file" do
      test_file = File.join(ENV['HOME'],'.tempo','tempo_animals.yaml')
      Tempo::Animal.save_all_to_file
      contents = eval_file_as_array( test_file )
      contents.must_equal ["---", ":id: 1", ":genious: hyla", ":species: h. versicolor",
                           "---", ":id: 2", ":genious: hyla", ":species: h. chrysoscelis",
                           "---", ":id: 4", ":genious: hyla", ":species: h. andersonii",
                           "---", ":id: 3", ":genious: hyla", ":species: h. avivoca",
                           "---", ":id: 5", ":genious: hyla", ":species: h. chinensis" ]
     end

    it "should grant children ability to read from a file" do
      test_file = File.join(ENV['HOME'],'.tempo','tempo_animals.yaml')
      File.delete(test_file) if File.exists?( test_file )
      file_lines = [ "---", ":id: 1", ":genious: hyla", ":species: h. versicolor",
                     "---", ":id: 2", ":genious: hyla", ":species: h. chrysoscelis",
                     "---", ":id: 4", ":genious: hyla", ":species: h. andersonii",
                     "---", ":id: 3", ":genious: hyla", ":species: h. avivoca",
                     "---", ":id: 5", ":genious: hyla", ":species: h. chinensis" ]
      File.open( test_file,'a' ) do |f|
        file_lines.each do |l|
          f.puts l
        end
      end
      Tempo::Animal.clear_all
      Tempo::Animal.read_from_file
      Tempo::Animal.ids.must_equal [1,2,3,4,5]
      Tempo::Animal.index.each do |animal|
        animal.id.must_be_kind_of(Integer)
        animal.genious.must_match "hyla"
        animal.species.must_match /^h\. \w./
      end
    end

    it "should give id as a readable attribute" do
      gray_tree_frog.id.must_equal 1
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