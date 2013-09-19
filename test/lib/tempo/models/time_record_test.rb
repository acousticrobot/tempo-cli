require "test_helper"

describe Tempo do

  before do
    # See Rakefile for directory prep and cleanup
    @dir = File.join( Dir.home,"tempo" )
    Dir.mkdir(@dir, 0700) unless File.exists?(@dir)
  end

  after do
    FileUtils.rm_r(@dir) if File.exists?(@dir)
  end

  describe "Model::TimeRecord" do

    it "should have project as an accessible attribute" do
      time_record_factory
      has_attr_accessor?( @record_1, :description ).must_equal true
    end

    it "should default to the current project" do
      project_factory
      Tempo::Model::TimeRecord.clear_all
      @record_1 = Tempo::Model::TimeRecord.new({ description: "day 1 pet the sheep",
                                                 start_time: Time.new(2014, 1, 1, 7 ) })
      @record_1.project.must_equal Tempo::Model::Project.current.id
    end

    it "should have and accessible description" do
      time_record_factory
      has_attr_accessor?( @record_1, :description ).must_equal true
    end

    it "should have readable tags" do
      time_record_factory
      has_attr_read_only?( @record_1, :tags ).must_equal true
    end

    it "should be taggable with an array of tags" do
      time_record_factory
      @record_2.tag(["fungi", "breakfast"])
      @record_2.tags.must_equal(["breakfast", "fungi"])
    end

    it "should be untaggable with an array of tags" do
      time_record_factory
      @record_3.untag( ["horticulture"] )
      @record_3.tags.must_equal(["trees"])
    end

    it "should have a current project getter" do
      time_record_factory
      Tempo::Model::TimeRecord.current.must_equal @record_6
      @record_6.end_time.must_equal :running
    end

    it "should close out the last current project on new" do
      time_record_factory
      @record_1.end_time.must_equal @record_2.start_time
      @record_2.end_time.must_equal @record_3.start_time

      @record_4.end_time.must_equal @record_5.start_time
      @record_5.end_time.must_equal @record_6.start_time
    end

    it "should close projects on the start day" do
      time_record_factory
      @record_3.end_time.must_equal Time.new(2014,1,1,23,59)
    end

    it "should close out new projects when a more recent project exists" do
      project_factory
      Tempo::Model::TimeRecord.clear_all
      @record_2 = Tempo::Model::TimeRecord.new({ project: @project_2, description: "day 1 drinking coffee, check on the mushrooms", start_time: Time.new(2014, 1, 1, 7, 30 ) })
      @record_1 = Tempo::Model::TimeRecord.new({ project: @project_1, description: "day 1 pet the sheep", start_time: Time.new(2014, 1, 1, 7 ) })
      Tempo::Model::TimeRecord.current.must_equal @record_2
      @record_1.end_time.must_equal @record_2.start_time
    end

    it "should error if start time coincides with an existing project" do
      time_record_factory
      proc { Tempo::Model::TimeRecord.new({ start_time: Time.new(2014, 1, 1, 12 ) }) }.must_raise ArgumentError
    end

    it "should come with freeze dry for free" do
      Tempo::Model::TimeRecord.clear_all
      time_record_factory
      @record_3.freeze_dry.must_equal({ :start_time=>Time.new(2014,1,1,17,30), :id=>3, :project=>3,
                                        :end_time=>Time.new(2014,1,1,23,59), :description=>"day 1 water the bonsai",
                                        :tags=>["horticulture", "trees"], :project_title=>"horticulture - backyard bonsai"})
    end

    it "should save to file a collection of projects" do
      time_record_factory
      Tempo::Model::TimeRecord.save_to_file
      test_file_1 = File.join(ENV['HOME'],'tempo/tempo_time_records/20140101.yaml')
      test_file_2 = File.join(ENV['HOME'],'tempo/tempo_time_records/20140102.yaml')
      contents = eval_file_as_array( test_file_1 )
      contents.must_equal [ "---", ":start_time: 2014-01-01 07:00:00.000000000 -05:00",
                            ":id: 1", ":project: 1", ":end_time: 2014-01-01 07:30:00.000000000 -05:00",
                            ":description: day 1 pet the sheep", ":tags: []", ":project_title: sheep herding",
                            "---", ":start_time: 2014-01-01 07:30:00.000000000 -05:00",
                            ":id: 2", ":project: 2", ":end_time: 2014-01-01 17:30:00.000000000 -05:00",
                            ":description: day 1 drinking coffee, check on the mushrooms",
                            ":tags: []", ":project_title: horticulture - basement mushrooms",
                            "---", ":start_time: 2014-01-01 17:30:00.000000000 -05:00",
                            ":id: 3", ":project: 3", ":end_time: 2014-01-01 23:59:00.000000000 -05:00",
                            ":description: day 1 water the bonsai",
                            ":tags:", "- horticulture", "- trees", ":project_title: horticulture - backyard bonsai"]
      contents = eval_file_as_array( test_file_2 )
      contents.must_equal [ "---", ":start_time: 2014-01-02 07:15:00.000000000 -05:00",
                            ":id: 1", ":project: 1", ":end_time: 2014-01-02 07:45:00.000000000 -05:00",
                            ":description: day 2 pet the sheep", ":tags: []", ":project_title: sheep herding",
                            "---", ":start_time: 2014-01-02 07:45:00.000000000 -05:00",
                            ":id: 2", ":project: 2", ":end_time: 2014-01-02 17:00:00.000000000 -05:00",
                            ":description: day 2 drinking coffee, check on the mushrooms",
                            ":tags: []", ":project_title: horticulture - basement mushrooms",
                            "---", ":start_time: 2014-01-02 17:00:00.000000000 -05:00",
                            ":id: 3", ":project: 3", ":end_time: :running",
                            ":description: day 2 water the bonsai",
                            ":tags: []", ":project_title: horticulture - backyard bonsai"]
    end
  end
end
