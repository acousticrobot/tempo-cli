# Create a new directory structure, copying the contents from
# directory_structure/tempo into ~/tempo.
# If a directory is passed in through the options, the tempo directory
# will be created within that directory instead, in the users home folder
#
# ex. create new(directory: "custom/directory")
# => Users/usrname/custom/directory/tempo

module FileRecord
  class Directory

    class << self

      def create_new(options={})

        directory = options.fetch( :directory, Dir.home )
        cwd = File.expand_path File.dirname(__FILE__)
        source = File.join(cwd, "directory_structure/tempo")
        if ! Dir.exists? directory
          FileUtils.mkdir_p directory
        end
        FileUtils.cp_r source, directory
      end
    end
  end
end
