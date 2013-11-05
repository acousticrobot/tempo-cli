require "test_helper"

#TODO Useful tree traversal methods should become view helpers?
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

        it "adds itself to the Reporter" do
          length_before = Tempo::Views::Reporter.view_records.length
          record = Tempo::Views::ViewRecords::Message.new "a message view record"
          Tempo::Views::Reporter.view_records.length.must_equal length_before + 1
        end
      end
    end
  end
end