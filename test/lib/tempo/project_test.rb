require "test_helper"

describe Tempo do
  describe "Project" do

    it "should inherit readable only id" do
      project_factory
      inherits_attr_read_only?( @project_1, :id ).must_equal true
    end

    it "should have accessible title" do
      project_factory
      has_attr_accessor?( @project_1, :title ).must_equal true
    end

    it "should have accessible tags" do
      project_factory
      has_attr_accessor?( @project_1, :tags ).must_equal true
    end

    # activate sub project when tree structure is implemented
    it "should not have accessible sub projects" do
      project_factory
      has_attr_accessor?( @project_1, :sub_projects ).must_equal false
    end

    it "should come with freeze dry for free" do
      project_factory
      @project_3.freeze_dry.must_equal({:id=>3, :title=>"horticulture - backyard bonsai", :tags=>["trees", "farming", "miniaturization"]})
    end

    it "should save to file a collection of projects" do
      project_factory
      test_file = File.join(ENV['HOME'],'.tempo','tempo_projects.yaml')
      Tempo::Model::Project.save_to_file
      contents = eval_file_as_array( test_file )
      contents.must_equal [ "---", ":id: 1", ":title: sheep hearding", ":tags: []",
                            "---", ":id: 2", ":title: horticulture - basement mushrooms", ":tags:", "- fungi", "- farming", ":current: true",
                            "---", ":id: 3", ":title: horticulture - backyard bonsai", ":tags:", "- trees", "- farming", "- miniaturization"]
    end

    it "should return an alphabatized list of project titles" do
      project_factory
      Tempo::Model::Project.list.must_equal [ "horticulture - backyard bonsai", "horticulture - basement mushrooms", "sheep hearding" ]
    end

    it "should have a current project getter" do
      project_factory
      Tempo::Model::Project.current.must_equal @project_2
    end

    it "should have a current project setter" do
      project_factory
      Tempo::Model::Project.current @project_3
      Tempo::Model::Project.current.must_equal @project_3
    end

    it "should not set a current non-existant project" do
      project_factory
      proc { Tempo::Model::Project.current( Tempo::Model::Base.new() )}.must_raise ArgumentError
    end

    it "should take current in args to new instance" do
      project_factory
      project_4 = Tempo::Model::Project.new({ title: 'horticulture - basement mushrooms', current: true})
      Tempo::Model::Project.current.must_equal project_4
    end

    it "should save current in freeze dry" do
      project_factory
      @project_2.freeze_dry.must_equal({ :id=>2, :title=>"horticulture - basement mushrooms", :tags=>[ "fungi", "farming" ], :current=>true})
    end
  end
end
