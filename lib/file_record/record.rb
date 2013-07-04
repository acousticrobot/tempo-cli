module FileRecord
  class Record

    def self.create( file, record, opts={} )
      puts "FILE: #{file} and RECORD: #{record}"
      opts[:format] ||= 'string'
      File.open( file,'w' ) do |f|
        if opts[:format] = 'string'
          f.puts record
        else
          # record.each do |r|
          # file.puts r.to_s
          #end
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