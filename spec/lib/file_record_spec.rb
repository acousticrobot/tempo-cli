require "spec_helper"
require "tempo.rb"
require "pry"

describe "File Record" do

  before(:each) do
    puts "runs first before"
    @dir = File.join(Dir.home, ".tempo_test_directory")
    Dir.mkdir(@dir, 0700) unless File.exists?(@dir)
  end

  after(:each) do
    # Warning don't fuck around here!
    FileUtils.rm_r @dir
  end

  describe "create" do

    before(:each) do
      @file = File.join( @dir, "create-test.txt")
    end

    after(:each) do
      if File.exists?( @file )
        File.delete( @file )
      end
    end

    describe "recording a string" do

      it "should create a new file" do

        FileRecord::Record.create( @file, "" )
        expect File.exists?( @file ).should eql(true)
      end

      it "should be able to record a string" do

        FileRecord::Record.create( @file, "a simple string" )
        contents = file_contents_as_array( @file )
        expect contents.should eql(["a simple string"])
      end
    end

    describe "recording and array" do

      it "should be able to record an array" do
        FileRecord::Record.create( @file, ["a","simple","array"] )
        contents = file_contents_as_array( @file )
        expect contents.should eql(["a","simple","array"])
      end
    end
  end
end