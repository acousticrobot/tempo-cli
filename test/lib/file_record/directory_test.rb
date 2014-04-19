require 'test_helper'

describe FileRecord do

  before do
    @dir = File.join(Dir.home,"tempo")
    @alt_dir = File.join(Dir.home, "testdir", "tempo")
    FileUtils.rm_r @dir if File.exists?(@dir)
  end

  after do
    FileUtils.rm_r @dir if File.exists?(@dir)
    FileUtils.rm_r @alt_dir if File.exists?(@alt_dir)
  end


  describe "Directory" do

    describe "initialize" do

      it "should initialize a new directory structure" do
        project_file = File.join(@dir, "tempo_projects.yaml")
        readme = File.join(@dir, "README.txt")

        FileRecord::Directory.create_new
        File.exists?( @dir ).must_equal true
        File.exists?( project_file ).must_equal true
        File.exists?( readme ).must_equal true
      end

      it "should take an optional directory parameter" do
        project_file = File.join(@alt_dir, "tempo_projects.yaml")
        readme = File.join(@alt_dir, "README.txt")
        dir = File.join(Dir.home, "testdir")

        FileRecord::Directory.create_new directory: dir
        File.exists?( @alt_dir ).must_equal true
        File.exists?( project_file ).must_equal true
        File.exists?( readme ).must_equal true
      end
    end
  end
end
