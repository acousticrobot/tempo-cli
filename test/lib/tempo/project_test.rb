require "test_helper"

describe Tempo do
  describe "Project" do

    p = Tempo::Project.new

    it "should have readable only id" do
      has_attr_read_only?(p, :id).must_equal true
    end

    it "should have accessible title" do
      has_attr_accessor?(p, :title).must_equal true
    end

    it "should have accessible tags" do
      has_attr_accessor?(p, :tags).must_equal true
    end

    it "should not have accessible sub projects" do
      has_attr_accessor?(p, :sub_projects).must_equal false
    end

  end
end