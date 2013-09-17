module Tempo
  module Model
    class TimeRecord < Tempo::Model::Log
      attr_accessor :project, :start_time, :end_time, :description
      attr_reader :tags

      class << self

      end

      def initialize(params={})
        super params
        @project = params[:project].id
        @end_time = params.fetch(:end_time, :running )
        @description = params.fetch(:description, "" )
        @tags = []
        tag params.fetch(:tags, [])

        # close out other time records if ! end_time
      end

      def freeze_dry
        record = super
        record[:project_title] = Project.find_by_id( @project ).title
        record
      end

      def tag( tags )
        return unless tags and tags.kind_of? Array
        tags.each do |tag|
          tag.split.each {|t| @tags << t if ! @tags.include? t }
        end
        @tags.sort!
      end

      def untag( tags )
        return unless tags and tags.kind_of? Array
        tags.each do |tag|
          tag.split.each {|t| @tags.delete t }
        end
      end
    end
  end
end
