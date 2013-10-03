module Tempo
  module Controllers
    class Records < Tempo::Controllers::Base
      @projects = Model::Project

      class << self

        def initialize_from_records options, args
          if File.exists?( File.join( ENV['HOME'], 'tempo' ))

            Tempo::Controllers::Projects.load

          else
            FileRecord::Directory.create_new
          end
        end

      end #class << self
    end
  end
end