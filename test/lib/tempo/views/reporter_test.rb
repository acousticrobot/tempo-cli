require "test_helper"

describe Tempo do
  describe "Views" do
    describe "Reporter" do
      it "adds and reports formats" do
        Tempo::Views::Reporter.add_format :html, :json, :logs
        Tempo::Views::Reporter.formats.must_equal [:html, :json, :logs]
      end

      it "collects view records as they are initialized" do
        Tempo::Views::Reporter.clear_records
        record_1 = Tempo::Views::ViewRecords::Message.new "a message to report"
        record_2 = Tempo::Views::ViewRecords::Message.new "a second message to report"
        record_3 = Tempo::Views::ViewRecords::Message.new "a third message to report"

        Tempo::Views::Reporter.view_records.length.must_equal 3
      end

      it "raises and error when view records of unknown format" do
        record = "an invalid record object"
        proc { Tempo::Views::Reporter.add_view_record record }.must_raise Tempo::Views::InvalidViewRecordError
      end

      it "sends the reports to the screen formatter on report" do
        Tempo::Views::Reporter.clear_records
        record_1 = Tempo::Views::ViewRecords::Message.new "a message to report"

        out = capture_stdout { Tempo::Views::Reporter.report }
        assert_equal "a message to report\n", out.string
      end

      it "has a mutable collection of options" do
        assert_equal Tempo::Views::Reporter.options, {}
        Tempo::Views::Reporter.add_options({ tags: true, depth: 3, color: "red" })
        assert_equal Tempo::Views::Reporter.options, { :tags=>true, :depth=>3, :color=>"red" }
      end
    end
  end
end