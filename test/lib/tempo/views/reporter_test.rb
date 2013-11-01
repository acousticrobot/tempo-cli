require "test_helper"

module Tempo
  module Views
    class Reporter
      def self.clear_records
        @@view_records = []
      end
    end
  end
end

describe Tempo do
  describe "Views" do
    describe "Reporter" do
      it "adds and reports formats" do
        Tempo::Views::Reporter.add_format :html, :json, :logs
        Tempo::Views::Reporter.formats.must_equal [:html, :json, :logs]
      end

      it "collects a view record" do
        Tempo::Views::Reporter.clear_records
        record = Tempo::Views::ViewRecords::Message.new "a message to report"
        Tempo::Views::Reporter.add_view_record record
        Tempo::Views::Reporter.view_records.length.must_equal 1
      end

      it "collects multiple view records" do
        Tempo::Views::Reporter.clear_records
        record_1 = Tempo::Views::ViewRecords::Message.new "a message to report"
        record_2 = Tempo::Views::ViewRecords::Message.new "a second message to report"
        record_3 = Tempo::Views::ViewRecords::Message.new "a third message to report"

        Tempo::Views::Reporter.add_view_record record_1, record_2, record_3
        Tempo::Views::Reporter.view_records.length.must_equal 3
      end

      it "raises and error when view records of unknown format" do
        record = "an invalid record object"
        proc { Tempo::Views::Reporter.add_view_record record }.must_raise Tempo::Views::InvalidViewRecordError
      end
    end
  end
end