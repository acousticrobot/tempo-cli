# Handles the CRUD of base, composite and log models
# relies on file utility to manage the directories and filenames.

require 'yaml'

module FileRecord
  class Record
    class << self

      # record a child of Tempo::Model::Base
      def save_model( model, options={} )

        options = options.dup
        options[:create] = true
        options[:destroy] = true

        file_path = FileUtility.new(model, options).file_path

        File.open( file_path,'a' ) do |f|
          model.index.each do |m|
            f.puts YAML::dump( m.freeze_dry )
          end
        end
      end

      # record a child of Tempo::Model::Log
      def save_log( model, options={} )

        options = options.dup
        options[:create] = true
        options[:destroy] = true

        model.days_index.each do |day, days_logs|

          options[:time] = day
          ut = FileUtility.new(model, options)

          # don't create an empty file
          next if days_logs.empty?

          ut.save_instances_to_file days_logs
        end
      end

      # Used by read_model and read_log to load all instances from a file
      #
      def read_instances( model, file, options={} )
        instances = YAML::load_stream( File.open( file ) )
        instances.each do |i|
          model.new( i )
        end
      end

      # Read in all models instances from the model file
      def read_model( model, options={} )

        file_path = FileUtility.new(model, options).file_path
        read_instances model, file_path
      end

      # Read in all log model instances from a time stamped file
      def read_log( model, time, options={} )

        options[:time] = time
        file_path = FileUtility.new(model, options).file_path

        if File.exists? file_path
          read_instances model, file_path
        end
      end
    end
  end
end
