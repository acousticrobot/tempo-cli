module Tempo
  module Model
    class Time < Tempo::Model::Base
      attr_accessor :start_time, :end_time, :description
      attr_reader :project

      class << self

      end

      def initialize(params={})
        super params
        @project = params[:project].id
        @start_time = params.fetch(:start_time, "now" )
      end

      def freeze_dry
        record = super
        record[:project_title] = Projects.find_by_id( @project ).title
        record
      end
    end
  end
end
