module Tempo
  class Project < Tempo::Model
    attr_accessor :title, :tags

    def initialize(params={})
      super params
      @title = params.fetch(:title, "new project")
      @tags = params.fetch(:tags, [])
    end

    def to_s
      puts "#{id}, #{title}, #{tags}"
    end
  end
end
