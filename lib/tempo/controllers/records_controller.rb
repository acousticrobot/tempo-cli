module Tempo
  module Controllers
    class Records < Tempo::Controllers::Base
      @projects = Model::Project

      class << self

        def initialize_from_records options, args

          dir = File.join( options.fetch( :directory, ENV['HOME']))

          if File.exists?(File.join(dir, 'tempo'))

            Tempo::Controllers::Projects.load directory: dir

          else
            FileRecord::Directory.create_new directory: dir
          end
        end

      end #class << self
    end
  end
end
