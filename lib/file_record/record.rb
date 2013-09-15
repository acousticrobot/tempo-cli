module FileRecord
  class Record
    class << self

      # record text as a string, and all objects as yaml
      # don't write over an existing document unless :force = true
      # @params file file path to record to
      # @params record string or object to record
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

      def log_dirname( model )
        dir_name = model.name[14..-1].gsub(/([A-Z])/, '_\1').downcase
        dir = "tempo#{dir_name}s"
      end

      def log_filename( model, time )
        file = "#{model.date_id( time )}.yaml"
      end

      def model_filename( model )
        file_name = model.name[14..-1].gsub(/([A-Z])/, '_\1').downcase
        file = "tempo#{file_name}s.yaml"
      end

      # record a child of Tempo::Model::Base
      def save_model( model )
        file = model_filename model
        file_path = File.join(Dir.home,'tempo', file)
        File.delete( file_path ) if File.exists?( file_path )

        File.open( file_path,'a' ) do |f|
          model.index.each do |m|
            f.puts YAML::dump( m.freeze_dry )
          end
        end
      end

      # record a child of Tempo::Model::Log
      def save_log( model )
        dir_name = log_dirname model
        dir = File.join(Dir.home,'tempo', dir_name)
        Dir.mkdir(dir, 0700) unless File.exists?(dir)

        model.index.each do |day, days_logs|
          file = "#{day.to_s}.yaml"
          file_path = File.join(dir, file)
          File.delete( file_path ) if File.exists?( file_path )

          File.open( file_path,'a' ) do |f|
            days_logs.each do |log|
              f.puts YAML::dump( log.freeze_dry )
            end
          end
        end
      end

      def read_instances( model, file )
        instances = YAML::load_stream( File.open( file ) )
        instances.each do |i|
          model.new( i )
        end
      end

      def read_model( model )
        file = File.join(Dir.home,'tempo', model.file)
        read_instances model, file
      end

      def read_log( model, time )
        dir = File.join(Dir.home,'tempo', model.dir)
        file = File.join(dir, model.file( time ))
        read_instances model, file
      end
    end

    def update

    end

    def delete

    end
  end
end
