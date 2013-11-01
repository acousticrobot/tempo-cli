require "test_helper"

describe Tempo do
  describe "Views" do
    describe "ViewRecords" do
      describe "Log" do
        before do
          log_factory
          @record = Tempo::Views::ViewRecords::Log.new @log_1
        end

        it "has a start_time and date id attribute" do
          @record.d_id.must_equal "20140101"
          @record.start_time.must_equal Time.new(2014, 1, 1, 7 )
        end

        it "has a default format" do
          @record.format.must_equal "Messagelog 20140101-1 07:00"
        end

        it "accepts a formatting block" do
          f = @record.format {|m| "#{m.d_id}-#{m.id}"}
          f.must_equal "20140101-1"
        end
      end
    end
  end
end