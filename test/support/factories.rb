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
      @id_counter = 1
    end
  end
end

def pantherinae_factory
  Tempo::Animal.clear_all
  pantherinae = [ { genious: "Panthera", species: "p. tigris" },
                  { genious: "Panthera", species: "p. leo"},
                  { genious: "Panthera", species: "p. onca"},
                  { genious: "Panthera", species: "p. pardus"},
                  { genious: "Panthera", species: "p. zdanskyi"}]

  pantherinae.each do |p|
    Tempo::Animal.new(p)
  end
end


def frog_factory
  Tempo::Animal.clear_all
  @gray_tree_frog = Tempo::Animal.new( { genious: "hyla", species: "h. versicolor" } )
  @copes_gray_tree_frog = Tempo::Animal.new( { genious: "hyla", species: "h. chrysoscelis"})
  @pine_barrens_tree_frog = Tempo::Animal.new( { genious: "hyla", species: "h. andersonii", id: 4 } )
  @bird_voiced_tree_frog = Tempo::Animal.new( { genious: "hyla", species: "h. avivoca"} )
  @chinese_tree_frog = Tempo::Animal.new( { genious: "hyla", species: "h. chinensis"} )
end
