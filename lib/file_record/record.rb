# Handles the CRUD of base, composite and log models
# relies on file utility to manage the directories and filenames.

require 'yaml'

module FileRecord
  class Record
    class << self

      # record text as a string, and all objects as yaml
      # don't write over an existing document unless :force = true
      # @options file file path to record to
      # @options record string or object to record
      # options
      #  - force: true, overwrite file
      #  - format: 'yaml', 'string'
      def create( file, record, options={} )

        if record.is_a?(String)
          format = options.fetch(:format, 'string')
        else
          format = options.fetch(:format, 'yaml')
        end

        if File.exists?(file)
          raise ArgumentError.new "file already exists" unless options[:force]
        end

        File.open( file,'w' ) do |f|

          case format
          when 'yaml'
            f.puts YAML::dump( record )
          when 'string'
            f.puts record
          else
            f.puts record
          end
        end
      end

      # # X-> File Util?
      # def log_dirname( model )
      #   dir_name = model.name[14..-1].gsub(/([A-Z])/, '_\1').downcase
      #   dir = "tempo#{dir_name}s"
      # end

      # # X-> File Util?
      # def log_dir( model )
      #   dir_name = log_dirname model
      #   dir = File.join(Dir.home,'tempo', dir_name)
      #   Dir.mkdir(dir, 0700) unless File.exists?(dir)
      #   dir
      # end

      # X-> File Util?
      def log_filename( model, time )
        file = "#{model.day_id( time )}.yaml"
      end

      # X-> File Util?
      def model_filename( model )
        file_name = model.name[14..-1].gsub(/([A-Z])/, '_\1').downcase
        file = "tempo#{file_name}s.yaml"
      end

      # record a child of Tempo::Model::Base
      def save_model( model, options={} ) #@done

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
      def save_log( model, options={} ) #@done

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
      def read_instances( model, file, options={} ) #@done
        instances = YAML::load_stream( File.open( file ) )
        instances.each do |i|
          model.new( i )
        end
      end

      # Read in all models instances from the model file
      def read_model( model, options={} ) #@done

        file_path = FileUtility.new(model, options).file_path
        read_instances model, file_path
      end

      # Read in all log model instances from a time stamped file
      def read_log( model, time, options={} ) #@done

        options[:time] = time
        file_path = FileUtility.new(model, options).file_path

        if File.exists? file_path
          read_instances model, file_path
        end
      end
    end

    def update

    end

    def delete

    end
  end
end
