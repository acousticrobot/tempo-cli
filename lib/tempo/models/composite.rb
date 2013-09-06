module Tempo
  module Model
    class Composite < Tempo::Model::Base
      attr_accessor :parent, :children

      class << self

        def report_trees
          report_array = "["
          @index.each do |member|
            if member.parent == :root
              report_array += "["
              report_array += member.report_branches
              report_array += "],"
            end
          end
          if report_array[-1] == ","
            report_array = report_array[0..-2]
          end
          report_array += "]"
        end
      end

      def initialize(params={})
        super params
        @parent = params.fetch(:parent, :root)
        @children = params.fetch(:children, [])
      end

      def << child
        @children << child.id
        @children.sort!
        child.parent = self.id
      end

      def delete_child( child )
        @children.delete child.id
        child.parent = :root
      end

      def report_branches
        report = self.id.to_s
        child_report = ",["
        @children.each do |c|
          child = self.class.find_by_id c
          child_report += "#{child.report_branches},"
        end
        if child_report == ",["
          child_report = ""
        else
          child_report = child_report[0..-2] + "]"
        end
        report += child_report
      end
    end
  end
end
