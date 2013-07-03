module Tempo
  class Project
    attr_accessor :id, :title, :tags, :sub_projects

    def initialize(id = -1, title = "new project", tags = [], sub_projects = [])
      @id = id
      @title = title
      @tags = tags
      @sub_projects = sub_projects
    end
  end
end
