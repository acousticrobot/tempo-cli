require "test_helper"

describe Tempo do
  describe "Views" do
    describe "Formatters" do
      describe "Base" do
        it "should be able to return a formatted record" do
          view_records_factory
          formatter = Tempo::Views::Formatters::Base.new
          formatter.add @message
          formatter.view.must_equal ["All The Things I Did"]
        end

        it "should be able to return formatted records" do
          view_records_factory
          formatter = Tempo::Views::Formatters::Base.new
          formatter.add @records
          formatter.view.must_equal ["All The Things I Did", "Project 1", "07:00 - 07:30  [0:30] sheep herding: day 1 pet the sheep"]
        end

        it "should raise messages when category is error" do
          view_records_factory
          formatter = Tempo::Views::Formatters::Base.new
          proc { formatter.add @error }.must_raise RuntimeError
        end
      end
    end
  end
end