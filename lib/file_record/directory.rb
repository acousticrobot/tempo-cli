require 'stringio'
require 'rubygems/package'
require 'rubygems/package'
require 'zlib'


module FileRecord
  class Directory

    class << self


      # Create a new directory structure, copying the contents from
      # directory_structure/tempo into ~/tempo.
      # If a directory is passed in through the options, the tempo directory
      # will be created within that directory instead, in the users home folder
      #
      # ex. create new(directory: "custom/directory")
      # => Users/usrname/custom/directory/tempo

      def create_new(options={})

        directory = options.fetch(:directory, Dir.home)
        cwd = File.expand_path File.dirname(__FILE__)
        source = File.join(cwd, "directory_structure/tempo")
        if ! Dir.exists? directory
          FileUtils.mkdir_p directory
        end
        FileUtils.cp_r source, directory
      end

      # Backup the tempo directory to tempo_backup_20140101_HrMnS.tar.gz
      # pass in an optional directory (see create_new)
      # Pass in a timestamp, or default to 20140101_120000
      def backup(options={})
        directory = options.fetch(:directory, Dir.home)
        timestamp = options.fetch(:timestamp, Time.new.strftime("%y%m%d_%H%M%S"))
        source = File.join(directory, "tempo")
        destination = File.join(directory, "tempo_backup_#{timestamp}.tar.gz")

        io = tar(source)
        gz = gzip(io)

        File.open(destination,"w") do |file|
           file.binmode
           file.write gz.read
        end

        # return the new directory name
        destination
      end

      private

      # COMPRESSION / DECOMPRESSION
      # From: https://gist.github.com/sinisterchipmunk/1335041

      # Creates a tar file in memory recursively
      # from the given dir.
      #
      # Returns a StringIO whose underlying String
      # is the contents of the tar file.
      def tar(dir)
        tarfile = StringIO.new("")
        Gem::Package::TarWriter.new(tarfile) do |tar|
          Dir[File.join(dir, "**/*")].each do |file|
            mode = File.stat(file).mode
            relative_file = file.sub /^#{Regexp::escape dir}\/?/, ''

            if File.directory?(file)
              tar.mkdir relative_file, mode
            else
              tar.add_file relative_file, mode do |tf|
                File.open(file, "rb") { |f| tf.write f.read }
              end
            end
          end
        end

        tarfile.rewind
        tarfile
      end

      # gzips the underlying string in the given StringIO,
      # returning a new StringIO representing the
      # compressed file.
      def gzip(tarfile)
        gz = StringIO.new("")
        z = Zlib::GzipWriter.new(gz)
        z.write tarfile.string
        z.close # this is necessary!

        # z was closed to write the gzip footer, so
        # now we need a new StringIO
        StringIO.new gz.string
      end

      # un-gzips the given IO, returning the
      # decompressed version as a StringIO
      def ungzip(tarfile)
        z = Zlib::GzipReader.new(tarfile)
        unzipped = StringIO.new(z.read)
        z.close
        unzipped
      end

      # untars the given IO into the specified
      # directory
      def untar(io, destination)
        Gem::Package::TarReader.new io do |tar|
          tar.each do |tarfile|
            destination_file = File.join destination, tarfile.full_name

            if tarfile.directory?
              FileUtils.mkdir_p destination_file
            else
              destination_directory = File.dirname(destination_file)
              FileUtils.mkdir_p destination_directory unless File.directory?(destination_directory)
              File.open destination_file, "wb" do |f|
                f.print tarfile.read
              end
            end
          end
        end
      end
    end
  end
end
