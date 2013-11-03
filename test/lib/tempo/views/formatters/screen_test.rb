require "test_helper"

describe Tempo do
  describe "Views" do
    describe "Formatters" do
      describe "Screen" do

        before do
          view_records_factory
          @formatter = Tempo::Views::Formatters::Screen.new
        end

        describe "Message View Records" do

          it "outputs the message" do
            records = [@message_1, @message_2]

            out = capture_stdout do
              @formatter.format_records records
            end

            assert_equal "All The Things I Did\non a busy busy day\n", out.string
          end

          it "raises an error when type error" do
            proc { @formatter.format_records [@error] }.must_raise RuntimeError
          end
        end

        describe "Duration View Records" do

          it "outputs the duration" do
            records = [@duration]

            out = capture_stdout do
              @formatter.format_records records
            end
            assert_equal "2:40\n", out.string
          end
        end

        describe "Project View Records" do

          it "outputs the project title" do
            records = [@project]
          end

        end

        describe "Time Record View Records" do

        end
      end
    end
  end
end
