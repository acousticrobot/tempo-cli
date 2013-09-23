module Tempo
  module Model
    class TimeRecord < Tempo::Model::Log
      attr_accessor :project, :start_time, :end_time, :description
      attr_reader :tags

      class << self

        def current
          @current
        end

        def current=( instance )
          if instance.class == self
            @current = instance
          else
            raise ArgumentError
          end
        end
      end

      def initialize(params={})
        @project_title = nil
        @description = params.fetch(:description, "" )
        @start_time = nil
        @end_time = params.fetch(:end_time, :running )

        super params

        project = params.fetch(:project, Tempo::Model::Project.current )
        @project = project.kind_of?( Integer ) ? project : project.id

        @tags = []
        tag params.fetch(:tags, [])

        # close out other time records if ! end_time
        if @end_time == :running
          if not self.class.current
            self.class.current = self
          else

            verify_open_time @start_time

            current = self.class.current

            # more recent entries exist, need to close out immediately
            if current.start_time > @start_time
              if current.start_time.day > @start_time.day
                out = end_of_day @start_time
                @end_time = out
                # TODO add a new record onto the next day
              else
                @end_time = current.start_time
              end

            # close out the last current record
            else
              if @start_time.day > current.start_time.day
                out = end_of_day current.start_time
                self.class.current.end_time = out
                self.class.current = self
                # TODO new record onto the next day
              else
                current.end_time = @start_time
                self.class.current = self
              end
            end
          end
        end
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

      private

      def verify_open_time time
        dsym = self.class.date_symbol time
        self.class.days_index[dsym].each do |record|
          if time > record.start_time
            next if record.end_time == :running or record == self.class.current
            if record.end_time - record.start_time > time - record.start_time
              raise ArgumentError, "Time conflict with existing record"
            end
          end
        end
        true
      end

      def end_of_day time
        Time.new(time.year, time.month, time.day, 23, 59)
      end
    end
  end
end
