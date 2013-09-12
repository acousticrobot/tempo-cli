require "test_helper"

describe Tempo do

  before do
    # See Rakefile for directory prep and cleanup
    @dir = File.join( Dir.home,"tempo" )
    Dir.mkdir(@dir, 0700) unless File.exists?(@dir)
  end

  describe "Model::Composite" do

    it "should inherit readable only id" do
      tree_factory
      inherits_attr_read_only?( @forest[0], :id ).must_equal true
    end

    it "should find a project by id" do
      tree_factory
      project = Tempo::Model::Tree.find_by_id(4)
      project.must_equal @forest[3]
    end

    it "should come with freeze dry for free" do
      tree_factory
      @forest[2].freeze_dry.must_equal({:id=>3, :parent=>1, :children=>[7,8], :position=>"branch1"})
    end

    it "should save to file a collection of composits" do
      tree_factory
      test_file = File.join(ENV['HOME'],'tempo','tempo_trees.yaml')
      Tempo::Model::Tree.save_to_file
      contents = eval_file_as_array( test_file )
      contents.must_equal [ "---", ":id: 1", ":parent: :root", ":children:", "- 3", ":position: root1",
                            "---", ":id: 2", ":parent: :root", ":children:", "- 4", "- 5", ":position: root2",
                            "---", ":id: 3", ":parent: 1", ":children:", "- 7", "- 8", ":position: branch1",
                            "---", ":id: 4", ":parent: 2", ":children: []", ":position: branch2",
                            "---", ":id: 5", ":parent: 2", ":children:", "- 6", ":position: branch3",
                            "---", ":id: 6", ":parent: 5", ":children: []", ":position: branch4",
                            "---", ":id: 7", ":parent: 3", ":children: []", ":position: leaf1",
                            "---", ":id: 8", ":parent: 3", ":children: []", ":position: leaf2"]
    end

    it "should revive a tree structure from a file" do
       tree_factory
       test_file = File.join(ENV['HOME'],'tempo','tempo_trees.yaml')
       File.delete(test_file) if File.exists?( test_file )
       contents = Tempo::Model::Tree.save_to_file
       Tempo::Model::Tree.clear_all
       Tempo::Model::Tree.read_from_file
       branch1 = Tempo::Model::Tree.find_by_id 3
       branch1.parent.must_equal 1
       branch1.children.must_equal [7,8]
    end

    it "should have a << child method" do
      tree_factory
      @forest[1] << @forest[2]
      @forest[1].freeze_dry.must_equal({:id=>2, :parent=>:root, :children=>[3,4,5], :position=>"root2"})
      @forest[2].freeze_dry.must_equal({:id=>3, :parent=>2, :children=>[7,8], :position=>"branch1"})
    end

    it "should have a report method" do
      tree_factory
      forest_array = Tempo::Model::Tree.report_trees
      forest_array.must_equal "[[1,[3,[7,8]]],[2,[4,5,[6]]]]"
    end
  end
end
