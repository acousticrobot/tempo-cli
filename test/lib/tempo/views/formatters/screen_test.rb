require "test_helper"

describe Tempo do
  describe "Views" do
    describe "Formatters" do
      describe "Screen" do

        it "outputs message view records" do
          view_records_factory
          records = [@message_1, @message_2]
          formatter = Tempo::Views::Formatters::Screen.new

          out = capture_stdout do
            formatter.format_records records
          end

          assert_equal "All The Things I Did\non a busy busy day\n", out.string
        end

        it "raises an error on message view records of type error" do
          view_records_factory
          formatter = Tempo::Views::Formatters::Screen.new
          proc { formatter.format_records [@error] }.must_raise RuntimeError
        end
      end
    end
  end
end