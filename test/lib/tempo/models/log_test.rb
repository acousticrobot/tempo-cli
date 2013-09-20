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

  describe "Model::Log" do

    it "should inherit the freeze-dry method" do
      log_factory
      frozen = @log_4.freeze_dry
      frozen.must_equal({ :start_time=>Time.new(2014, 01, 02, 07, 15),
                          :id=>1, :message=>"day 2 pet the sheep"})
    end

    it "should inherit the same indexing method" do
      log_factory
      Tempo::Model::MessageLog.index.length.must_equal 6
    end

    it "should also have a days indexing method" do
      log_factory
      Tempo::Model::MessageLog.days_index.length.must_equal 2
      Tempo::Model::MessageLog.days_index[:"20140101"].length.must_equal 3
      Tempo::Model::MessageLog.days_index[:"20140102"].length.must_equal 3
    end

    it "should create a file name to save to" do
      log_factory
      date = Time.new(2014,1,1)
      Tempo::Model::MessageLog.file(date).must_equal "20140101.yaml"
    end

    it "should grant children the ability to write to a file" do
      log_factory
      test_dir = File.join(ENV['HOME'],'tempo','tempo_message_logs')
      # FileUtils.rm_r test_dir if File.exists?(test_dir)
      Tempo::Model::MessageLog.save_to_file
      test_file_1 = File.join(test_dir, "20140101.yaml")
      test_file_2 = File.join(test_dir, "20140102.yaml")
      contents = eval_file_as_array( test_file_1 )
      contents.must_equal [ "---", ":start_time: 2014-01-01 07:00:00.000000000 -05:00",
                            ":id: 1", ":message: day 1 pet the sheep",
                            "---", ":start_time: 2014-01-01 07:30:00.000000000 -05:00",
                            ":id: 2", ":message: day 1 drinking coffee, check on the mushrooms",
                            "---", ":start_time: 2014-01-01 12:30:00.000000000 -05:00",
                            ":id: 3", ":message: day 1 water the bonsai"]
      contents = eval_file_as_array( test_file_2 )
      contents.must_equal [ "---", ":start_time: 2014-01-02 07:15:00.000000000 -05:00",
                            ":id: 1", ":message: day 2 pet the sheep",
                            "---", ":start_time: 2014-01-02 07:45:00.000000000 -05:00",
                            ":id: 2", ":message: day 2 drinking coffee, check on the mushrooms",
                            "---", ":start_time: 2014-01-02 12:00:00.000000000 -05:00",
                            ":id: 3", ":message: day 2 water the bonsai"]
     end

    it "should grant children ability to read from a file" do
      log_record_factory
      time = Time.new(2014, 1, 2, 5, 30)
      Tempo::Model::MessageLog.read_from_file time
      Tempo::Model::MessageLog.ids( time ).must_equal [1,2,3]
      Tempo::Model::MessageLog.index[0].message.must_equal "day 2 pet the sheep"
    end

    it "should load the days index before adding new" do
      log_record_factory
      new_record = Tempo::Model::MessageLog.new({ message: "day 1 pet the sheep",
                                                  start_time: Time.new(2014, 1, 2, 7 ) })
      new_record.id.must_equal 4
    end

    it "should give id as a readable attribute" do
      log_factory
      @log_6.id.must_equal 3
    end

    it "should raise an error on duplicate id" do
      log_factory
      args = {  message: "duplicate id",
                start_time: Time.new(2014, 1, 1, 3 ),
                id: 1
              }
      proc { Tempo::Model::MessageLog.new( args ) }.must_raise Tempo::Model::IdentityConflictError
    end

    it "should find logs by id" do
      log_factory
      search = Tempo::Model::MessageLog.find("id", 2 )
      search.must_equal [ @log_2, @log_5 ]
    end

    it "should have a day_id method" do
      day_id = Tempo::Model::MessageLog.day_id Time.new(2014, 1, 1)
      day_id.must_equal "20140101"
    end

    it "should have a find_by_id using day_id method" do
      log_factory
      search = Tempo::Model::MessageLog.find_by_id( 2, "20140101" )
      search.must_equal [ @log_2 ]

      search = Tempo::Model::MessageLog.find_by_id( 2, "20140102" )
      search.must_equal [ @log_5 ]
    end

    it "should have a find_by_id using time method" do
      log_factory
      search = Tempo::Model::MessageLog.find_by_id( 2, Time.new(2014, 1, 1))
      search.must_equal  [ @log_2 ]
      search = Tempo::Model::MessageLog.find_by_id( 2, Time.new(2014, 1, 2))
      search.must_equal [ @log_5 ]
    end

    it "should have a sort_by_start_time method" do
      list = Tempo::Model::MessageLog.sort_by_start_time [ @log_5, @log_1, @log_3 ]
      list.must_equal [ @log_1, @log_3, @log_5 ]
    end

    it "should have a delete instance method" do
      log_factory
      @log_1.delete
      Tempo::Model::MessageLog.ids(Time.new(2014,1,1)).must_equal [2,3]
      Tempo::Model::MessageLog.index.must_equal [ @log_4, @log_2, @log_5, @log_3, @log_6 ]
    end
  end
end
