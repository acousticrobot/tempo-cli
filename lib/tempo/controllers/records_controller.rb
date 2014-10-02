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
          Views::interactive_progress "Backing up #{dir}/tempo"

          if File.exists?(File.join(dir, 'tempo'))
            dest = FileRecord::Directory.backup directory: dir
            Views::interactive_progress "Sucessfully created #{dest}"
          else
            Views::no_items("directory #{dir}/tempo", :error)
          end
        end

        def clean_records(options, args)

          dir = File.join( options.fetch( :directory, ENV['HOME']), "tempo", "tempo_time_records")
          Views::interactive_progress "Loading records from #{dir}"

          days = Model::TimeRecord.record_d_ids(options)

          options[:round_time] = true
          days.each do |d_id|
            Views::interactive_progress_partial "#{d_id[4..5].to_i}/#{d_id[6..7]}/#{d_id[0..3]}"
            Model::TimeRecord.load_day_record(d_id, options)
            Model::TimeRecord.save_to_file(options)
            Model::TimeRecord.clear_all
          end
        end
      end #class << self
    end
  end
end
