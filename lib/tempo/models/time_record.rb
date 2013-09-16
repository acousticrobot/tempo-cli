module Tempo
  module Model
    class TimeRecord < Tempo::Model::Log
      attr_accessor :project, :start_time, :end_time, :description
      attr_reader :tags

      class << self

      end

      def initialize(params={})
        super params
        @project = params[:project]
        @start_time = params.fetch(:start_time, "now" )
        @end_time = params[:end]
        @description = params[:description]
        @tags = []
        tag params.fetch(:tags, [])

        # close out other time records if ! end_time
      end

      def freeze_dry
        record = super
        record[:project_title] = Projects.find_by_id( @project ).title
        record
      end

      def tag( tags )
        return unless tags and tags.kind_of? Array
        tags.each do |tag|
          tag.split.each {|t_t| @tags << t_t }
        end
        @tags.sort!
      end

      def untag( tags )
        return unless tags and tags.kind_of? Array
        tags.each do |tag|
          tag.split.each {|t_t| @tags.delete t_t }
        end
      end
    end
  end
end
