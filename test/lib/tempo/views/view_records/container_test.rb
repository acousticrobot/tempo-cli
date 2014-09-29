require "test_helper"

describe Tempo do
  describe "Views" do
    describe "ViewRecords" do

      describe "Container" do

        it "has a type, pre,and post attribute" do
          pre = Tempo::Views::ViewRecords::Message.new "pre message"
          post = Tempo::Views::ViewRecords::Message.new "post message"
          container = Tempo::Views::ViewRecords::Container.new pre: pre, post: post
          container.type.must_equal "container"
          container.pre.message.must_equal "pre message"
          container.post.message.must_equal "post message"
        end

        it "has adds and contains a collection of view records" do
          container = Tempo::Views::ViewRecords::Container.new
          m1 = Tempo::Views::ViewRecords::Message.new "first message", postpone: true
          m2 = Tempo::Views::ViewRecords::Message.new "second message", postpone: true
          m3 = Tempo::Views::ViewRecords::Message.new "third message", postpone: true
          [m1, m2, m3].each { |m| container.add m }
          container.records.must_equal [m1,m2,m3]
        end

        it "adds itself to the Reporter" do
          length_before = Tempo::Views::Reporter.view_records.length
          record = Tempo::Views::ViewRecords::Container.new
          Tempo::Views::Reporter.view_records.length.must_equal length_before + 1
        end

        it "doesn't add itself with options postpone" do
          length_before = Tempo::Views::Reporter.view_records.length
          record = Tempo::Views::ViewRecords::Message.new "a message view record", postpone: true
          Tempo::Views::Reporter.view_records.length.must_equal length_before
        end
      end

      describe "TimeRecordContainer" do
        # TODO: Write ViewRecord Time Record tests first
        # then add time records to a time records container
        # test the total time is accurate
      end
    end
  end
end
