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

    it "should come with freeze dry for free" do
      time_record_factory
      @record_3.freeze_dry.must_equal({ :start_time=>Time.new(2014,1,1,12,30),
                                        :id=>3, :project=>3,
                                        :end_time=>:running, :description=>"day 1 water the bonsai",
                                        :tags=>["horticulture", "trees"],
                                        :project_title=>"horticulture - backyard bonsai" })
    end

    it "should save to file a collection of projects" do
      time_record_factory
      Tempo::Model::TimeRecord.save_to_file
      test_file_1 = File.join(ENV['HOME'],'tempo/tempo_time_records/20140101.yaml')
      test_file_2 = File.join(ENV['HOME'],'tempo/time_records/20140102.yaml')
      contents = eval_file_as_array( test_file_1 )
      contents.must_equal [ "---", ":start_time: 2014-01-01 07:00:00.000000000 -05:00", ":id: 1", ":project: 1", ":end_time: :running",
                            ":description: day 1 pet the sheep", ":tags: []", ":project_title: sheep herding",
                            "---", ":start_time: 2014-01-01 07:30:00.000000000 -05:00", ":id: 2", ":project: 2", ":end_time: :running",
                            ":description: day 1 drinking coffee, check on the mushrooms", ":tags: []", ":project_title: horticulture - basement mushrooms",
                            "---", ":start_time: 2014-01-01 12:30:00.000000000 -05:00", ":id: 3", ":project: 3", ":end_time: :running",
                            ":description: day 1 water the bonsai", ":tags:", "- horticulture", "- trees", ":project_title: horticulture - backyard bonsai"]
    end
  end
end
