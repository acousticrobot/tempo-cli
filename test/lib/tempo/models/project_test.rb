require "test_helper"

describe Tempo do

  before do
    # See Rakefile for directory prep and cleanup
    @dir = File.join( Dir.home,"tempo" )
    Dir.mkdir(@dir, 0700) unless File.exists?(@dir)
  end

  describe "Model::Project" do

    it "inherits readable only id" do
      project_factory
      inherits_attr_read_only?( @project_1, :id ).must_equal true
    end

    it "has accessible title" do
      project_factory
      has_attr_accessor?( @project_1, :title ).must_equal true
    end

    it "has readable tags" do
      project_factory
      has_attr_read_only?( @project_1, :tags ).must_equal true
    end

    it "is taggable with an array of tags" do
      project_factory
      @project_2.tag(["seasonal", "moist"])
      @project_2.tags.must_equal(["farming", "fungi", "moist", "seasonal"])
    end

    it "is untaggable with an array of tags" do
      project_factory
      @project_3.untag( ["farming", "miniaturization"] )
      @project_3.tags.must_equal(["trees"])
    end

    it "comes with freeze dry for free" do
      project_factory
      @project_3.freeze_dry.must_equal({:id=>3, :parent=>4, :children=>[],
                                        :title=>"horticulture - backyard bonsai",
                                        :tags=>["farming", "miniaturization", "trees"]})
    end

    it "saves to file a collection of projects" do
      project_factory
      test_file = File.join(ENV['HOME'],'tempo','tempo_projects.yaml')
      Tempo::Model::Project.save_to_file
      contents = eval_file_as_array( test_file )
      contents.must_equal [ "---", ":id: 1", ":parent: :root", ":children: []", ":title: sheep herding", ":tags: []",
                            "---", ":id: 2", ":parent: 4", ":children: []", ":title: horticulture - basement mushrooms", ":tags:", "- farming", "- fungi", ":current: true",
                            "---", ":id: 3", ":parent: 4", ":children: []", ":title: horticulture - backyard bonsai", ":tags:", "- farming", "- miniaturization", "- trees",
                            "---", ":id: 4", ":parent: :root", ":children:", "- 2", "- 3", ":title: gardening", ":tags: []"]
    end

    it "returns an boolean to the include? method" do
      project_factory
      Tempo::Model::Project.include?("bonsai").must_equal false
      Tempo::Model::Project.include?("horticulture - backyard bonsai").must_equal true
    end

    it "has a current project getter" do
      project_factory
      Tempo::Model::Project.current.must_equal @project_2
    end

    it "has a current project setter" do
      project_factory
      Tempo::Model::Project.current = @project_3
      Tempo::Model::Project.current.must_equal @project_3
    end

    it "has a current boolean method" do
      project_factory
      @project_2.current?.must_equal true
      @project_3.current?.must_equal false
    end

    it "can not set current to a non-existant project" do
      project_factory
      proc { Tempo::Model::Project.current = Tempo::Model::Base.new }.must_raise ArgumentError
    end

    it "takes current in args to new instance" do
      project_factory
      project_4 = Tempo::Model::Project.new({ title: 'horticulture - basement mushrooms', current: true})
      Tempo::Model::Project.current.must_equal project_4
    end

    it "saves current in freeze dry" do
      project_factory
      @project_2.freeze_dry.must_equal({:id=>2, :parent=>4, :children=>[],
                                        :title=>"horticulture - basement mushrooms",
                                        :tags=>["farming", "fungi"], :current=>true})
    end

    it "finds a project by id" do
      project_factory
      project = Tempo::Model::Project.find_by_id(1)
      project.must_equal @project_1
    end
  end
end
