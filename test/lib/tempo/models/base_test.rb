require "test_helper"
require "pry"

describe Tempo do

  before do
    # See Rakefile for directory prep and cleanup
    @dir = File.join( Dir.home,"tempo" )
    Dir.mkdir(@dir, 0700) unless File.exists?(@dir)
  end

  describe "Model::Base" do

    it "should be a easy to inherit from" do
      Tempo::Model::Animal.superclass.must_equal Tempo::Model::Base
    end

    it "should grant child objects the freeze-dry method" do
      frog_factory
      frozen = @gray_tree_frog.freeze_dry
      frozen.must_equal( {:id=>1, :genious=>"hyla", :species=>"h. versicolor"} )
    end

    it "should grant child objects a self indexing method" do
      frog_factory
      Tempo::Model::Animal.index.length.must_equal 5
      Tempo::Model::Animal.index.each do |animal|
        animal.id.must_be_kind_of(Integer)
        animal.genious.must_match "hyla"
        animal.species.must_match /^h\. \w./
      end
    end

    it "should create a file name to save to" do
      frog_factory
      Tempo::Model::Animal.file.must_equal "tempo_animals.yaml"
    end

    it "should grant children the ability to write to a file" do
      frog_factory
      test_file = File.join(ENV['HOME'],'tempo','tempo_animals.yaml')
      File.delete(test_file) if File.exists?( test_file )
      contents = Tempo::Model::Animal.save_to_file
      contents = eval_file_as_array( test_file )
      contents.must_equal ["---", ":id: 1", ":genious: hyla", ":species: h. versicolor",
                           "---", ":id: 2", ":genious: hyla", ":species: h. chrysoscelis",
                           "---", ":id: 4", ":genious: hyla", ":species: h. andersonii",
                           "---", ":id: 3", ":genious: hyla", ":species: h. avivoca",
                           "---", ":id: 5", ":genious: hyla", ":species: h. chinensis" ]
     end

    it "should grant children ability to read from a file" do
      test_file = File.join(ENV['HOME'],'tempo','tempo_animals.yaml')
      File.delete(test_file) if File.exists?( test_file )
      file_lines = [ "---", ":id: 11", ":genious: hyla", ":species: h. versicolor",
                     "---", ":id: 12", ":genious: hyla", ":species: h. chrysoscelis",
                     "---", ":id: 14", ":genious: hyla", ":species: h. andersonii",
                     "---", ":id: 13", ":genious: hyla", ":species: h. avivoca",
                     "---", ":id: 15", ":genious: hyla", ":species: h. chinensis" ]
      File.open( test_file,'a' ) do |f|
        file_lines.each do |l|
          f.puts l
        end
      end
      Tempo::Model::Animal.clear_all
      Tempo::Model::Animal.read_from_file
      Tempo::Model::Animal.ids.must_equal [11,12,13,14,15]
      Tempo::Model::Animal.index.each do |animal|
        animal.id.must_be_kind_of(Integer)
        animal.genious.must_match "hyla"
        animal.species.must_match /^h\. \w./
      end
    end

    it "should give id as a readable attribute" do
      frog_factory
      @gray_tree_frog.id.must_equal 1
    end

    it "should manage uniqe ids" do
      frog_factory
      @copes_gray_tree_frog.id.must_equal 2
    end

    it "should handle ids assigned and out of order" do
      frog_factory
      Tempo::Model::Animal.ids.must_equal [1,2,3,4,5]
      @pine_barrens_tree_frog.id.must_equal 4
      @bird_voiced_tree_frog.id.must_equal 3
      @chinese_tree_frog.id.must_equal 5
    end

    it "should raise an error on duplicate id" do
      frog_factory
      args = {  genious: "hyla",
                species: "h. flatulus",
                id: 1
              }
      proc { gassy_tree_frog = Tempo::Model::Animal.new( args ) }.must_raise Tempo::Model::IdentityConflictError
    end

    it "should find matching instances of the class" do
      frog_factory
      search = Tempo::Model::Animal.find("id", 2)
      search.must_equal [ @copes_gray_tree_frog ]

      search = Tempo::Model::Animal.find("species", "h. versicolor" )
      search.must_equal [ @gray_tree_frog ]

      search = Tempo::Model::Animal.find("species", /h\. / )
      search.length.must_equal 5
    end

    it "should have a find_by_  method" do
      frog_factory
      search = Tempo::Model::Animal.find_by_id(2)
      search.must_equal @copes_gray_tree_frog

      search = Tempo::Model::Animal.find_by_species("h. versicolor")
      search.must_equal [ @gray_tree_frog ]

      search = Tempo::Model::Animal.find_by_genious("hyla")
      search.length.must_equal 5

      search = Tempo::Model::Animal.find_by_genious_and_species("hyla", /versicolor/)
      search.must_equal [ @gray_tree_frog ]
    end

    it "should have a sort_by_ method" do
      frog_factory
      list = Tempo::Model::Animal.sort_by_species [ @gray_tree_frog, @pine_barrens_tree_frog ]
      list.must_equal [ @pine_barrens_tree_frog, @gray_tree_frog ]

      list = Tempo::Model::Animal.sort_by_id [ @gray_tree_frog, @pine_barrens_tree_frog ]
      list.must_equal [ @gray_tree_frog, @pine_barrens_tree_frog ]

      list = Tempo::Model::Animal.sort_by_species
      list.must_equal [ @pine_barrens_tree_frog, @bird_voiced_tree_frog,
                        @chinese_tree_frog, @copes_gray_tree_frog, @gray_tree_frog ]

      list = Tempo::Model::Animal.sort_by_species do |frog|
        species_list = ""
        frog.each do |f|
          species_list += "#{f.species}, "
        end
        species_list[0..-3]
      end
      list.must_equal "h. andersonii, h. avivoca, h. chinensis, h. chrysoscelis, h. versicolor"
    end

    it "should still have a method_missing method" do
      proc { Tempo::Model::Animal.foo }.must_raise NoMethodError
    end

    it "should have a delete instance method" do
      frog_factory
      @gray_tree_frog.delete
      Tempo::Model::Animal.ids.must_equal [2,3,4,5]
    end
  end
end
