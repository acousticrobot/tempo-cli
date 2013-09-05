require "test_helper"

describe Tempo do
  describe "Model::Composite" do

    it "should inherit readable only id" do
      tree_factory
      inherits_attr_read_only?( @forest[0], :id ).must_equal true
    end

    it "should come with freeze dry for free" do
      tree_factory
      @forest[2].freeze_dry.must_equal({ :id=>3, :position=>"branch1" })
    end

    it "should save to file a collection of composits" do
      skip "test base first"
      tree_factory
      test_file = File.join(ENV['HOME'],'.tempo','tempo_composits.yaml')
      Tempo::Model::Project.save_to_file
      contents = eval_file_as_array( test_file )
      contents.must_equal [ "---", ":id: 1", ":title: sheep hearding", ":tags: []",
                            "---", ":id: 2", ":title: horticulture - basement mushrooms", ":tags:", "- farming", "- fungi", ":current: true",
                            "---", ":id: 3", ":title: horticulture - backyard bonsai", ":tags:", "- farming", "- miniaturization", "- trees"]    end

    it "should find a project by id" do
      skip "test base first"
      tree_factory
      project = Tempo::Model::Project.find_by_id(1)
      project.must_equal @project_1
    end
  end
end
