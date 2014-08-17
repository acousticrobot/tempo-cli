module Tempo
  module Controllers
    class Records < Tempo::Controllers::Base
      @projects = Model::Project

      class << self

        def initialize_from_records(options, args)

          dir = options.fetch( :directory, ENV['HOME'])

          if File.exists?(File.join(dir, 'tempo'))
            Tempo::Controllers::Projects.load directory: dir
          else
            FileRecord::Directory.create_new directory: dir
          end
        end

        def backup_records(options, args)
          dir = options.fetch( :directory, ENV['HOME'])
          Views::message("Backing up #{dir}/tempo...")

          if File.exists?(File.join(dir, 'tempo'))
            dest = FileRecord::Directory.backup directory: dir
            Views::message("Sucessfully created #{dest}")
          else
            Views::no_items("directory #{dir}/tempo", :error)
          end
        end

        def clean_records(options, args)
          dir = File.join( options.fetch( :directory, ENV['HOME']), "tempo", "tempo_time_records")
          Views::message("Loading records from #{dir}")

          all_files = Dir["#{dir}/*.yaml"]
          # if including subfolders
          # Dir["/path/to/search/**/*.rb"]

          all_files.each do |f|
            Views::message("Loading records for #{f}", :verbose)
          end
        end
      end #class << self
    end
  end
end
