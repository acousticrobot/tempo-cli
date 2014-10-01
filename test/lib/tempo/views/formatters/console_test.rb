require "test_helper"

describe Tempo do
  describe "Views" do
    describe "Formatters" do
      describe "Console" do

        before do
          view_records_factory
        end

        describe "Message View Records" do

          it "outputs the message" do
            record =  @progress_message
            formatter = Tempo::Views::Formatters::Console.new
            out = capture_stdout { formatter.report record }

            assert_equal "Making progress...\n", out.string
          end
        end

        describe "Interactive View Records" do

          it "outputs the interaction with a prompt" do
            # pending
          end
        end
      end
    end
  end
end
