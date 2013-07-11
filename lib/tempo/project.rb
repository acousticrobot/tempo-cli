module Tempo
  class Project
    attr_reader :id
    attr_accessor :title, :tags

    def initialize(id = -1, title = "new project", tags = [], sub_projects = [])
      @id = id
      @title = title
      @tags = tags
    end

    def to_s
      puts "#{id}, #{title}, #{tags}, #{sub_projects}"
    end
  end
end
