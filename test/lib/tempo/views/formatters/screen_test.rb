require "test_helper"

describe Tempo do
  describe "Views" do
    describe "Formatters" do
      describe "Screen" do

        before do
          view_records_factory
        end

        describe "Message View Records" do

          it "outputs the message" do
            records = [@message_1, @message_2]
            formatter = Tempo::Views::Formatters::Screen.new
            out = capture_stdout { formatter.format_records records }

            assert_equal "All The Things I Did\non a busy busy day\n", out.string
          end

          it "raises an error when type error" do
            formatter = Tempo::Views::Formatters::Screen.new
            proc { formatter.format_records [@error] }.must_raise RuntimeError
          end
        end

        describe "Duration View Records" do

          it "outputs the duration" do
            records = [@duration]
            formatter = Tempo::Views::Formatters::Screen.new
            out = capture_stdout { formatter.format_records records }

            assert_equal "2:40\n", out.string
          end
        end

        describe "Project View Records" do

          it "outputs the project title" do
            records = [@project_1]
            formatter = Tempo::Views::Formatters::Screen.new
            out = capture_stdout { formatter.format_records records }

            assert_equal "sheep herding\n", out.string
          end

          it "accepts option to include tags with spacing" do
            records = [@project_1, @project_2]
            formatter = Tempo::Views::Formatters::Screen.new tags: true
            out = capture_stdout { formatter.format_records records }

            assert_equal "sheep herding                      tags: none\n" +
                         "horticulture - basement mushrooms  tags: [farming, fungi]\n", out.string
          end

          it "accepts option to include id" do
            records = [@project_2]
            formatter = Tempo::Views::Formatters::Screen.new id: true
            out = capture_stdout { formatter.format_records records }

            assert_equal "  [2] horticulture - basement mushrooms\n", out.string
          end

          it "accepts option to indent projects to proper depth" do
            @project_1.depth = 3
            records = [@project_1]
            formatter = Tempo::Views::Formatters::Screen.new depth: true
            out = capture_stdout { formatter.format_records records}

            assert_equal "      sheep herding\n", out.string
          end

          it "indicates active project" do
            records = [@project_1, @project_2]
            formatter = Tempo::Views::Formatters::Screen.new active: true
            out = capture_stdout { formatter.format_records records }
            assert_equal "  sheep herding\n* horticulture - basement mushrooms\n", out.string
          end
        end

        describe "TimeRecord View Records" do
          it "has start/end time, duration, project and description" do
            records = [@time_record_1]
            formatter = Tempo::Views::Formatters::Screen.new
            out = capture_stdout { formatter.format_records records }

            assert_equal "07:00 - 07:30  [0:30] sheep herding: day 1 pet the sheep\n", out.string
          end

          it "outputs a running indicator" do
            records = [@time_record_6]
            formatter = Tempo::Views::Formatters::Screen.new
            out = capture_stdout { formatter.format_records records }

            assert_match /17:00 - \d{2}:\d{2}\*/, out.string
          end
        end
      end
    end
  end
end
