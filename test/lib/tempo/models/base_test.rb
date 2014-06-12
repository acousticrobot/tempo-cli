require "test_helper"

# Used to test define_method is called
# the first time a find_by_ and sort_by_
# is called. Don't use for any other tests
class Plant < Tempo::Model::Base
  attr_accessor :stem, :leaf

  def initialize( options={} )
    super options
    @stem = options.fetch(:stem, "woody")
    @leaf = options.fetch(:leaf, "broad")
  end
end


describe Tempo do

  before do
    # See Rakefile for directory prep and cleanup
    @dir = File.join( Dir.home,"tempo" )
    Dir.mkdir(@dir, 0700) unless File.exists?(@dir)
  end

  def after_teardown
    Tempo::Model::Animal.clear_all
    super
  end

  describe "Model::Base" do

    it "is inheritable from" do
      Tempo::Model::Animal.superclass.must_equal Tempo::Model::Base
    end

    it "grants child objects the freeze-dry method" do
      frog_factory
      frozen = @gray_tree_frog.freeze_dry
      frozen.must_equal( {:id=>1, :genious=>"hyla", :species=>"h. versicolor"} )
    end

    it "grants child objects a self indexing method" do
      frog_factory
      Tempo::Model::Animal.index.length.must_equal 5
      Tempo::Model::Animal.index.each do |animal|
        animal.id.must_be_kind_of(Integer)
        animal.genious.must_match "hyla"
        animal.species.must_match /^h\. \w./
      end
    end

    it "knows which file name to save to" do
      frog_factory
      Tempo::Model::Animal.file.must_equal "tempo_animals.yaml"
    end

    it "grants children the ability to write to a file" do
      frog_factory
      test_file = File.join(ENV['HOME'],'tempo','tempo_animals.yaml')
      File.delete(test_file) if File.exists?( test_file )
      contents = Tempo::Model::Animal.save_to_file
      contents = eval_file_as_array( test_file )
      contents.must_equal ["---", ":id: 1", ":genious: hyla", ":species: h. versicolor",
                           "---", ":id: 2", ":genious: hyla", ":species: h. chrysoscelis",
                           "---", ":id: 3", ":genious: hyla", ":species: h. avivoca",
                           "---", ":id: 4", ":genious: hyla", ":species: h. andersonii",
                           "---", ":id: 5", ":genious: hyla", ":species: h. chinensis" ]
     end

    it "grants children ability to read from a file" do
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

    it "gives id as a readable attribute" do
      frog_factory
      @gray_tree_frog.id.must_equal 1
    end

    it "manages uniqe ids" do
      frog_factory
      @copes_gray_tree_frog.id.must_equal 2
    end

    it "handles ids assigned and out of order" do
      frog_factory
      Tempo::Model::Animal.ids.must_equal [1,2,3,4,5]
      @pine_barrens_tree_frog.id.must_equal 4
      @bird_voiced_tree_frog.id.must_equal 3
      @chinese_tree_frog.id.must_equal 5
    end

    it "raises an error on duplicate id" do
      frog_factory
      args = {  genious: "hyla",
                species: "h. flatulus",
                id: 1
              }
      proc { gassy_tree_frog = Tempo::Model::Animal.new( args ) }.must_raise Tempo::Model::IdentityConflictError
    end

    it "finds matching instances of the class" do
      frog_factory
      search = Tempo::Model::Animal.find("id", 2)
      search.must_equal [ @copes_gray_tree_frog ]

      search = Tempo::Model::Animal.find("species", "h. versicolor" )
      search.must_equal [ @gray_tree_frog ]

      search = Tempo::Model::Animal.find("species", /h\. / )
      search.length.must_equal 5
    end

    it "uses case insensitivity searches" do
      frog_factory
      search = Tempo::Model::Animal.find("species", "Versicolor" )
      search.must_equal [ @gray_tree_frog ]
    end

    it "has a find_by_  method" do
      frog_factory
      search = Tempo::Model::Animal.find_by_id(2)
      search.must_equal @copes_gray_tree_frog

      search = Tempo::Model::Animal.find_by_species("h. versicolor")
      search.must_equal [ @gray_tree_frog ]

      search = Tempo::Model::Animal.find_by_species("Versicolor")
      search.must_equal [ @gray_tree_frog ]

      search = Tempo::Model::Animal.find_by_genious("hyla")
      search.length.must_equal 5

      search = Tempo::Model::Animal.find_by_genious_and_species("hyla", /versicolor/)
      search.must_equal [ @gray_tree_frog ]
    end

    it "responds to find_by_ method" do
      # Current behavior raises error if no instances exist.
      # This behavior could be relaxed, or models could be made
      # to explicity declare findable attributes
      frog_factory
      Tempo::Model::Animal.must_respond_to :find_by_species
    end

    it "doesn't respond to find_by_ method for non-existent attribute" do
      Tempo::Model::Animal.wont_respond_to :find_by_blah
      proc { Tempo::Model::Animal.find_by_blah 1 }.must_raise NoMethodError
    end

    it "defines find_by_ methods after first call" do
      plant = Plant.new
      Plant.methods.include?(:find_by_stem).must_equal false
      Plant.find_by_stem("woody")
      Plant.methods.include?(:find_by_stem).must_equal true
    end

    it "has a sort_by_ method" do
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

    it "responds to sort_by_ method" do
      # Current behavior raises error if no instances exist.
      # This behavior could be relaxed, or models could be made
      # to explicity declare sortable attributes
      frog_factory
      Tempo::Model::Animal.must_respond_to :sort_by_species
    end

    it "doesn't respond to sort_by_ method for non-existent attribute" do
      Tempo::Model::Animal.wont_respond_to :sort_by_blah
      proc { Tempo::Model::Animal.sort_by_blah }.must_raise NoMethodError
    end

    it "defines sort_by methods after first call" do
      plant = Plant.new
      Plant.methods.include?(:sort_by_stem).must_equal false
      Plant.sort_by_stem
      Plant.methods.include?(:sort_by_stem).must_equal true
    end

    it "has a method_missing method" do
      proc { Tempo::Model::Animal.foo }.must_raise NoMethodError
    end

    it "has a delete instance method" do
      frog_factory
      @gray_tree_frog.delete
      Tempo::Model::Animal.ids.must_equal [2,3,4,5]
    end
  end
end
