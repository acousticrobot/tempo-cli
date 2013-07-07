require "spec_helper"
require "tempo.rb"
require "pry"

describe "File Record" do

  before(:all) do
    @dir = File.join(Dir.home, ".tempo_test_directory")
    Dir.mkdir(@dir, 0700) unless File.exists?(@dir)
  end

  after(:all) do
    if File.exists?(@dir)
      FileUtils.rm_r @dir
    end
  end

  describe "create" do

    before(:all) do
      @file = File.join( @dir, "create-test.txt")
    end

    after(:each) do
      File.delete(@file)
    end

    it "should create a new file" do

      FileRecord::Record.create( @file, "" )
      expect File.exists?( @file ).should eql(true)
    end

    it "should raise an error if the file already exists" do
      File.open( @file,'w' ) do |f|
        f.puts "Now this file already exists"
      end
      expect{FileRecord::Record.create( @file, "" )}.to raise_error(ArgumentError)
    end

    it "should overwrite a file with option :force" do
      File.open( @file,'w' ) do |f|
        f.puts "Now this file already exists"
      end
      FileRecord::Record.create( @file, "overwrite file", force: true )
      contents = eval_file_as_array( @file )
      expect contents.should eql(["overwrite file"])
    end


    describe "recording a string" do

      it "should be able to record a string" do

        FileRecord::Record.create( @file, "a simple string" )
        contents = eval_file_as_array( @file )
        expect contents.should eql(["a simple string"])
      end

      it "should be able to record a string as yaml" do

        FileRecord::Record.create( @file, "a simple string", format: 'yaml' )
        contents = eval_file_as_array( @file )
        expect contents.should eql(["--- a simple string", "..."])
      end
    end

    describe "recording and array" do

      it "should be able to record a shallow array as string" do
        FileRecord::Record.create( @file, ["a","simple","array"], format: "string" )
        contents = eval_file_as_array( @file )
        expect contents.should eql(["a","simple","array"])
      end

      it "should default to recording a shallow array as yaml" do
        FileRecord::Record.create( @file, ["a","simple","array"] )
        contents = eval_file_as_array( @file )
        expect contents.should eql(["---", "- a", "- simple", "- array"])
      end

      it "should record a nested array as yaml" do
        FileRecord::Record.create( @file, ["a",["nested",["array"]]])
        contents = eval_file_as_array( @file )
        expect contents.should eql(["---", "- a", "- - nested", "  - - array"])
      end
    end

    describe "recording a hash" do

      it "should defualt to and record a hash as yaml" do
        hash = {a: 1, b: true, c: Hash.new, d: "object", with: ['an', 'array']}
        FileRecord::Record.create( @file, hash )
        contents = eval_file_as_array( @file )
        expect contents.should eql(["---", ":a: 1", ":b: true", ":c: {}", ":d: object", ":with:", "- an", "- array"])
      end
    end
  end
end