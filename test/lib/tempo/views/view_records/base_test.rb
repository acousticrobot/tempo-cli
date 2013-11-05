require "test_helper"

describe Tempo do
  describe "Views" do
    describe "ViewRecords" do

      describe "Message" do

        it "has a type, category,and message attribute" do
          record = Tempo::Views::ViewRecords::Message.new "a message view record"
          record.type.must_equal "message"
          record.category.must_equal :info
          record.message.must_equal "a message view record"

          record = Tempo::Views::ViewRecords::Message.new "an error message", category: :error
          record.category.must_equal :error
        end

        it "has a default format" do
          record = Tempo::Views::ViewRecords::Message.new "a message view record"
          record.format.must_equal "a message view record"
        end

        it "adds itself to the Reporter" do
          length_before = Tempo::Views::Reporter.view_records.length
          record = Tempo::Views::ViewRecords::Message.new "a message view record"
          Tempo::Views::Reporter.view_records.length.must_equal length_before + 1
        end
      end

      describe "Duration" do

        it "has a type of duration" do
          record = Tempo::Views::ViewRecords::Duration.new
          record.type.must_equal "duration"
        end

        it "starts with given seconds or default to zero" do
          record = Tempo::Views::ViewRecords::Duration.new
          record.total.must_equal 0

          record = Tempo::Views::ViewRecords::Duration.new 30
          record.total.must_equal 30
        end

        it "has add and subtract methods" do
          record = Tempo::Views::ViewRecords::Duration.new 30
          record.add 160
          record.total.must_equal 190
          record.subtract 50
          record.total.must_equal 140
        end

        it "has a default format" do

          record = Tempo::Views::ViewRecords::Duration.new 1800
          record.format.must_equal "0:30"

          record = Tempo::Views::ViewRecords::Duration.new 18000
          record.format.must_equal "5:00"

          record = Tempo::Views::ViewRecords::Duration.new 36300
          record.format.must_equal "10:05"

          record = Tempo::Views::ViewRecords::Duration.new 39000
          record.format.must_equal "10:50"
        end

        it "accepts a formatting block" do
          record = Tempo::Views::ViewRecords::Duration.new 39000
          formatted = record.format {|d| "I have a duration of #{d.total} seconds!"}
          formatted.must_equal "I have a duration of 39000 seconds!"
        end
      end
    end
  end
end