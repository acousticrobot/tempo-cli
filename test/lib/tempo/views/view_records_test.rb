require "test_helper"

#TODO Usful tree traversal methods should become view helpers
def parse_tree_to_composite_record records, options={}
  depth = options.fetch( :depth, 0 )
  parent = options.fetch( :parent, :root )
  view = []

  records.each do |r|
    if r.parent == parent
      v = Tempo::Views::ViewRecords::Composite.new r, depth: depth
      view << v
      if not r.children.empty?
        child_opts = options.clone
        child_opts[:depth] = depth + 1
        child_opts[:parent] = r.id
        child_array = parse_tree_to_composite_record records, child_opts
        view.push *child_array
      end
    end
  end

  view
end

describe Tempo do
  describe "Views" do
    describe "ViewRecords" do

      describe "Duration" do

        it "starts with given seconds or default to zero" do
          record = Tempo::Views::ViewRecords::Duration.new
          record.seconds.must_equal 0

          record = Tempo::Views::ViewRecords::Duration.new 30
          record.seconds.must_equal 30
        end

        it "has add and subtract methods" do
          record = Tempo::Views::ViewRecords::Duration.new 30
          record.add 160
          record.seconds.must_equal 190
          record.subtract 50
          record.seconds.must_equal 140
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
          formatted = record.format {|s| "I have a duration of #{s} seconds!"}
          formatted.must_equal "I have a duration of 39000 seconds!"
        end
      end

      describe "Model" do

        before do
          frog_factory
          @record = Tempo::Views::ViewRecords::Model.new @bird_voiced_tree_frog
        end

        it "has a type and id to start" do
          @record.id.must_equal 3
          @record.type.must_equal "animal"
        end

        it "has a default format" do
          @record.format.must_equal "Animal 3"
        end

        it "accepts a formatting block" do
          formatted = @record.format {|m| "#{m.type} no.#{m.id}"}
          formatted.must_equal "animal no.3"
        end
      end

      describe "Log" do
        before do
          log_factory
          @record = Tempo::Views::ViewRecords::Log.new @log_1
        end

        it "has a start_time and date id attribute" do
          @record.d_id.must_equal "20140101"
          @record.start_time.must_equal Time.new(2014, 1, 1, 7 )
        end

        it "has a default format" do
          @record.format.must_equal "Messagelog 20140101-1 07:00"
        end

        it "accepts a formatting block" do
          f = @record.format {|m| "#{m.d_id}-#{m.id}"}
          f.must_equal "20140101-1"
        end
      end

      describe "Composite" do
        before do
          tree_factory
          @record = parse_tree_to_composite_record Tempo::Model::Tree.index
        end

        it "has a depth attribute" do
          inspector = ""
          @record.each {|r| inspector += "<#{r.id}:#{r.depth}>"}
          inspector.must_equal "<1:0><3:1><7:2><8:2><2:0><4:1><5:1><6:2>"
        end

        it "has a default format" do
          @record[7].format.must_equal "    Tree 6"
        end

        it "has a class max depth" do
          Tempo::Views::ViewRecords::Composite.max_depth.must_equal 2
        end
      end

      describe "Time Record" do
        before do
          time_record_factory
          @r1 = Tempo::Views::ViewRecords::TimeRecord.new @record_1
          @r2 = Tempo::Views::ViewRecords::TimeRecord.new @record_2
          @r6 = Tempo::Views::ViewRecords::TimeRecord.new @record_6
        end

        it "has description end_time project running attributes" do
          @r1.description.must_equal "day 1 pet the sheep"
          @r1.end_time.must_equal Time.new( 2014, 1, 1, 7, 30 )
          @r1.project.must_equal "sheep herding"
          @r1.running.must_equal false
          @r6.running.must_equal true
        end

        it "has a duration record" do
          @r1.duration.seconds.must_equal 1800
        end

        it "has a class max description length" do
          Tempo::Views::ViewRecords::TimeRecord.max_description_length.must_equal @record_2.description.length
        end

        it "has a class max project length" do
          Tempo::Views::ViewRecords::TimeRecord.max_project_length.must_equal @record_2.project_title.length
        end

        it "has a default format" do
          @r1.format.must_equal "07:00 - 07:30  [0:30] sheep herding: day 1 pet the sheep"

          # check for the asterisk indicating a running project
          @r6.format.must_match /\d{2}:\d{2} - \d{2}:\d{2}\* \[-*\d+:\d{2}\]/
        end
      end

      describe "Project" do
        before do
          project_factory
          @p1 = Tempo::Views::ViewRecords::Project.new @project_1
          @p2 = Tempo::Views::ViewRecords::Project.new @project_2
          @p3 = Tempo::Views::ViewRecords::Project.new @project_3
        end

        it "has title and tag attributes" do
          @p1.title.must_equal 'sheep herding'
          @p2.tags.must_equal ["farming", "fungi"]
        end

        it "has a class max title length" do
          Tempo::Views::ViewRecords::Project.max_title_length.must_equal @project_2.title.length
        end

        it "inherits a depth attribute" do
          #@p2
        end

        it "has a default format" do
          #@p3.format.must_equal "[3] "
          #{}"id: #{id}, title: #{title}, tags: #{tags}"
        end
      end
    end
  end
end