module Tempo
  module Model
    class TimeRecord < Tempo::Model::Log
      attr_accessor :project, :description
      attr_reader :start_time, :end_time, :tags

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
        @description = params.fetch :description, ""
        @start_time = nil
        @end_time = params.fetch :end_time, :running

        super params

        #TODO: verify both start time ( and end time if ! :running )
        verify_open_time @start_time
        verify_open_time @end_time if @end_time.kind_of? Time

        project = params.fetch :project, Tempo::Model::Project.current
        @project = project.kind_of?(Integer) ? project : project.id

        @tags = []
        tag params.fetch(:tags, [])

        # close out other time records if ! end_time
        if running?
          if not self.class.current
            self.class.current = self
          else

            # verify_open_time @start_time

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
              else
                current.end_time = @start_time
                self.class.current = self
              end
            end
          end
        end
      end

      def end_time= time
        #TODO verify end time before save
        @end_time = time
      end

      def project_title
        Project.find_by_id( @project ).title
      end

      def duration
        if @end_time.kind_of? Time
          end_time = @end_time
        else
          end_time = Time.now()
        end
        end_time.to_i - @start_time.to_i
      end

      def running?
        @end_time == :running
      end

      def freeze_dry
        record = super
        record[:project_title] = project_title
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

      def to_s
        "#{@start_time.strftime('%H:%M')} - #{@end_time.strftime('%H:%M')} #{project_title}: #{@description}"
      end

      private

      # check a time against all loaded instances, verify that it doesn't
      # fall in the middle of any closed time records
      #
      def verify_open_time time
        dsym = self.class.date_symbol time
        return if not self.class.days_index[dsym]
        self.class.days_index[dsym].each do |record|
          if time > record.start_time

            # ignore running entries for now
            next if record.end_time == :running or record == self.class.current

            if record.end_time - record.start_time > time - record.start_time
              raise ArgumentError, "Time conflict with existing record: \n  #{record.to_s}"
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
