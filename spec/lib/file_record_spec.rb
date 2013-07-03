require "spec_helper"
require "tempo.rb"
require "pry"

describe "File Record" do

  describe "create" do

    FileRecord::Record.create("test.txt","a simple string")

    it "should create a new file" do
      expect File.exists?( "test.txt" ).should eql(true)
    end
  end
end