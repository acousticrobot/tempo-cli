module FileRecord
  class Record

    # record text as a string, and all objects as yaml
    # don't write over an existing document unless :force = true
    # @params file file path to record to
    # @params record string or object to record
    # options
    #  - force: true, overwrite file
    #  - format: 'yaml', 'string'
    def self.create( file, record, options={} )

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

    # record a child of Tempo::Model
    def self.model_save( model )
      file = model_filename model
      file_path = File.join(Dir.home,'tempo', file)
      File.delete( file_path ) if File.exists?( file_path )
      File.open( file_path,'a' ) do |f|
        model.index.each do |m|
          f.puts YAML::dump( m.freeze_dry )
        end
      end
    end

    def self.model_filename( model )
      file = "tempo_#{model.name[14..-1].downcase}s.yaml"
    end

    def read

    end

    def update

    end

    def delete

    end
  end
end