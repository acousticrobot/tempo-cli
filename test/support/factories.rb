module Tempo
  module Model

    class Base
      def self.clear_all()
        @ids = []
        @index = []
        @id_counter = 1
      end
    end

    class Animal < Tempo::Model::Base
      attr_accessor :genious, :species

      def initialize( params={} )
        super params
        @genious = params[:genious]
        @species = params.fetch(:species, @genious)
      end
    end

    class Tree < Tempo::Model::Composite
      attr_accessor :position

      def initialize( params={})
        super params
        @position = params[:position]
      end
    end
  end
end

def pantherinae_factory
  Tempo::Model::Animal.clear_all
  pantherinae = [ { genious: "Panthera", species: "p. tigris" },
                  { genious: "Panthera", species: "p. leo"},
                  { genious: "Panthera", species: "p. onca"},
                  { genious: "Panthera", species: "p. pardus"},
                  { genious: "Panthera", species: "p. zdanskyi"}]

  pantherinae.each do |p|
    Tempo::Model::Animal.new(p)
  end
end

def frog_factory
  Tempo::Model::Animal.clear_all
  @gray_tree_frog = Tempo::Model::Animal.new( { genious: "hyla", species: "h. versicolor" } )
  @copes_gray_tree_frog = Tempo::Model::Animal.new( { genious: "hyla", species: "h. chrysoscelis"})
  @pine_barrens_tree_frog = Tempo::Model::Animal.new( { genious: "hyla", species: "h. andersonii", id: 4 } )
  @bird_voiced_tree_frog = Tempo::Model::Animal.new( { genious: "hyla", species: "h. avivoca"} )
  @chinese_tree_frog = Tempo::Model::Animal.new( { genious: "hyla", species: "h. chinensis"} )
end

def tree_factory
  Tempo::Model::Tree.clear_all
  @forest = []

  trees = [{ position: "root1"},
            { position: "root2"},
            { position: "branch1"},
            { position: "branch2"},
            { position: "branch3"},
            { position: "branch4"},
            { position: "leaf1"},
            { position: "leaf2"}]
  trees.each do |t|
    @forest << Tempo::Model::Tree.new(t)
  end

  @forest[0] << @forest[2]
  @forest[2] << @forest[6]
  @forest[2] << @forest[7]
  @forest[1] << @forest[3]
  @forest[1] << @forest[4]
  @forest[4] << @forest[5]
end

def project_factory
  Tempo::Model::Project.clear_all
  @project_1 = Tempo::Model::Project.new title: 'sheep hearding'
  @project_2 = Tempo::Model::Project.new({ title: 'horticulture - basement mushrooms', tags: [ "fungi", "farming" ], current: true})
  @project_3 = Tempo::Model::Project.new({ title: 'horticulture - backyard bonsai', tags: [ "trees", "farming", "miniaturization" ]})
end

