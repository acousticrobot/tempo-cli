# Composite Model extends base to accomodate tree structures
# Each instance can be a root instance, or a child of another
# instance, and each instance can have any number of children.
# report_trees is a utility method for testing the validity of the
# model, and cam be used as a template for creating tree reports.

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

        def delete instance
          instance.children.each do |child_id|
            child = find_by_id child_id
            instance.remove_child child
          end
          super instance
        end
      end

      def initialize(options={})
        super options
        @parent = options.fetch(:parent, :root)
        @children = options.fetch(:children, [])
      end

      def << child
        @children << child.id unless @children.include? child.id
        @children.sort!
        child.parent = self.id
      end

      def remove_child( child )
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
