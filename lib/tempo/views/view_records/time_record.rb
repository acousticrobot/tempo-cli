module Tempo
  module Views
    module ViewRecords

      # TimeRecord adds a description, project and end_time and running flag
      # to the Log Record to represent any instance of the TimeRecord model.
      # It also includes a Duration ViewRecord for presenting the total duration
      # of the time record.
      #
      class TimeRecord < ViewRecords::Log
        attr_accessor :description, :duration, :end_time, :project, :running

        class << self
          def max_description_length len=0
            @max_description_length ||= 0
            @max_description_length = @max_description_length > len ? @max_description_length : len
          end

          def max_project_length len=0
            @max_project_length ||= 0
            @max_project_length = @max_project_length > len ? @max_project_length : len
          end
        end

        def initialize model, options={}
          super model, options
          @description = model.description
          @description ||= ""
          @duration = Duration.new model.duration
          @end_time = model.end_time == :running ? Time.now() : model.end_time
          @project = model.project_title
          @running = model.running?
          self.class.max_description_length @description.length
          self.class.max_project_length @project.length
        end

        def format &block
          block ||= lambda do |m|
            running = m.running ? "*" : " "
            description = @description ? "#{m.project}: #{m.description}" : "#{m.project}"
            "#{m.start_time.strftime('%H:%M')} - #{m.end_time.strftime('%H:%M')}#{running} [#{m.duration.format}] #{description}"
          end
          block.call self
        end
      end
    end
  end
end