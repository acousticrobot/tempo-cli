require "test_helper"

describe Tempo do
  describe "Project" do

    p = Tempo::Project.new

    it "should inherit readable only id" do
      inherits_attr_read_only?(p, :id).must_equal true
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

    it "should come with freeze-dry for free" do
      p2 = Tempo::Project.new({ title: "hang-gliding", tags: [ "dangerous", "weekends" ] })
      p2.freeze_dry.must_equal({:id=>2, :title=>"hang-gliding", :tags=>["dangerous", "weekends"]})
    end
  end
end