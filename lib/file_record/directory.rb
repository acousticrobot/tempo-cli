module FileRecord
  class Directory
    class << self
      def create_new
        cwd = File.expand_path File.dirname(__FILE__)
        source = File.join(cwd, "directory_structure/tempo")
        FileUtils.cp_r( source, Dir.home )
      end
    end
  end
end