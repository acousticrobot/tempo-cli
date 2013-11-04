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
            out = capture_stdout { @formatter.format_records records }

            assert_equal "All The Things I Did\non a busy busy day\n", out.string
          end

          it "raises an error when type error" do
            proc { @formatter.format_records [@error] }.must_raise RuntimeError
          end
        end

        describe "Duration View Records" do

          it "outputs the duration" do
            records = [@duration]
            out = capture_stdout { @formatter.format_records records }

            assert_equal "2:40\n", out.string
          end
        end

        describe "Project View Records" do

          it "outputs the project title" do
            records = [@project_1]
            out = capture_stdout { @formatter.format_records records }

            assert_equal "sheep herding\n", out.string
          end

          it "accepts option to include tags" do
            records = [@project_2]
            @formatter.add_options tags: true
            out = capture_stdout { @formatter.format_records records }

            assert_equal "horticulture - basement mushrooms       tags: [farming, fungi]\n", out.string
          end

          it "accepts option to include id" do
            records = [@project_2]
            @formatter.add_options id: true
            out = capture_stdout { @formatter.format_records records }

            assert_equal "[2] horticulture - basement mushrooms\n", out.string
          end

          it "indents projects to proper depth" do
            records = [@project_1]
            @formatter.add_options depth: 3
            out = capture_stdout { @formatter.format_records records }

            assert_equal "      sheep herding\n", out.string
          end

          it "indicates active project" do
            records = [@project_1, @project_2]
            @formatter.add_options active: true
            out = capture_stdout { @formatter.format_records records }
            assert_equal "  sheep herding\n* horticulture - basement mushrooms\n", out.string
          end

        end

        describe "TimeRecord View Records" do

        end
      end
    end
  end
end
