require 'test_helper'

describe FileRecord do

  before do
    # See Rakefile for directory prep and cleanup
    dir = File.join(Dir.home,"tempo")
    Dir.mkdir(dir, 0700) unless File.exists?(dir)
    @dir = File.join(Dir.home,"tempo", "tempo_unit_tests")
    Dir.mkdir(@dir, 0700) unless File.exists?(@dir)
  end

  describe "Record" do

    describe "recording a Tempo Model" do

      it "should create a record of all instances" do
        test_file = File.join(ENV['HOME'],'tempo','tempo_animals.yaml')
        File.delete( test_file ) if File.exists?( test_file )
        pantherinae_factory
        FileRecord::Record.save_model( Tempo::Model::Animal )
        contents = eval_file_as_array( test_file )
        contents.must_equal [ "---", ":id: 1", ":genious: Panthera", ":species: p. tigris",
                              "---", ":id: 2", ":genious: Panthera", ":species: p. leo",
                              "---", ":id: 3", ":genious: Panthera", ":species: p. onca",
                              "---", ":id: 4", ":genious: Panthera", ":species: p. pardus",
                              "---", ":id: 5", ":genious: Panthera", ":species: p. zdanskyi"]
      end
    end

    describe "recording a Tempo Log" do

      it "should create daily records containing each instance" do
        test_file_1 = File.join(ENV['HOME'],'tempo','tempo_message_logs', '20140101.yaml')
        File.delete( test_file_1 ) if File.exists?( test_file_1 )
        test_file_2 = File.join(ENV['HOME'],'tempo','tempo_message_logs', '20140102.yaml')
        File.delete( test_file_2 ) if File.exists?( test_file_2 )

        log_factory
        FileRecord::Record.save_log(Tempo::Model::MessageLog)
        contents = eval_file_as_array( test_file_1 )
        contents.must_equal [ "---",
                              ":start_time: 2014-01-01 07:00:00.000000000 -05:00",
                              ":id: 1",
                              ":message: day 1 pet the sheep",
                              "---",
                              ":start_time: 2014-01-01 07:30:00.000000000 -05:00",
                              ":id: 2",
                              ":message: day 1 drinking coffee, check on the mushrooms",
                              "---",
                              ":start_time: 2014-01-01 12:30:00.000000000 -05:00",
                              ":id: 3",
                              ":message: day 1 water the bonsai"]

        contents = eval_file_as_array( test_file_2 )
        contents.must_equal [ "---",
                              ":start_time: 2014-01-02 07:15:00.000000000 -05:00",
                              ":id: 1",
                              ":message: day 2 pet the sheep",
                              "---",
                              ":start_time: 2014-01-02 07:45:00.000000000 -05:00",
                              ":id: 2",
                              ":message: day 2 drinking coffee, check on the mushrooms",
                              "---",
                              ":start_time: 2014-01-02 12:00:00.000000000 -05:00",
                              ":id: 3",
                              ":message: day 2 water the bonsai"]
      end
    end

    describe "reading a Tempo Log" do
    end
  end
end
