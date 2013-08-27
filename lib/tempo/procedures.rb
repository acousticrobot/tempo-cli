module Tempo
  module Procedures

    def self.load_projects
      if File.exists?( File.join( ENV['HOME'], '.tempo', Tempo::Project.file ))
        Tempo::Project.read_from_file
        Tempo::Project
      end
    end

  end
end