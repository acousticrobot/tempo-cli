require "test_helper"

describe Tempo do
  describe "Project" do

    p = Tempo::Project.new title: 'sheep hearding'
    p2 = Tempo::Project.new({ title: 'horticulture - basement mushrooms', tags: [ "fungi", "farming" ]})
    p3 = Tempo::Project.new({ title: 'horticulture - backyard bonsai', tags: [ "trees", "farming", "miniaturization" ]})

    it "should inherit readable only id" do
      inherits_attr_read_only?(p, :id).must_equal true
    end

    it "should have accessible title" do
      has_attr_accessor?(p, :title).must_equal true
    end

    it "should have accessible tags" do
      has_attr_accessor?(p, :tags).must_equal true
    end

    # activate sub project when tree structure is implemented
    it "should not have accessible sub projects" do
      has_attr_accessor?(p, :sub_projects).must_equal false
    end

    it "should come with freeze-dry for free" do
      p2.freeze_dry.must_equal({:id=>2, :title=>"horticulture - basement mushrooms", :tags=>["fungi", "farming"]})
    end

    it "should save to file a collection of projects" do
      test_file = File.join(ENV['HOME'],'.tempo','tempo_projects.yaml')
      Tempo::Project.save_to_file
      contents = eval_file_as_array( test_file )
      contents.must_equal [ "---", ":id: 1", ":title: sheep hearding", ":tags: []",
                            "---", ":id: 2", ":title: horticulture - basement mushrooms", ":tags:", "- fungi", "- farming",
                            "---", ":id: 3", ":title: horticulture - backyard bonsai", ":tags:", "- trees", "- farming", "- miniaturization"]
    end

    it "should return an alphabatized list of projects by title" do
      Tempo::Project.list.must_equal [ "horticulture - backyard bonsai", "horticulture - basement mushrooms", "sheep hearding" ]
    end
  end
end
