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

    def read

    end

    def update

    end

    def delete

    end
  end
end