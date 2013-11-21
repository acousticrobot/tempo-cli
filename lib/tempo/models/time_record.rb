module Tempo
  module Model
    class TimeRecord < Tempo::Model::Log
      attr_accessor :project, :description
      attr_reader :start_time, :end_time, :tags

      class << self

        def current
          return @current if @current && @current.end_time == :running
          @current = nil
        end

        def current=( instance )
          if instance.class == self
            @current = instance
          else
            raise ArgumentError
          end
        end
      end

      def initialize(options={})

        # declare these first for model organization when sent to YAML
        @project_title = nil
        @description = options.fetch :description, ""
        @start_time = nil

        # verify both start time and end time before sending to super
        options[:start_time] ||= Time.now
        verify_start_time options[:start_time]
        @end_time = options.fetch :end_time, :running
        verify_end_time options[:start_time], @end_time

        super options

        project = options.fetch :project, Tempo::Model::Project.current
        @project = project.kind_of?(Integer) ? project : project.id

        @tags = []
        tag options.fetch(:tags, [])

        # close out other time records if ! end_time
        if running?
          if not self.class.current
            self.class.current = self
          else

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

        # close out any earlier running timerecords
        else
          if self.class.current
             if self.class.current.start_time < @start_time
               self.class.current.end_time = @start_time
             end
          end
        end
      end

      def end_time= time
        #TODO verify end time before save
        @end_time = time
      end

      def project_title
        Project.find_by_id( @project ).title if @project
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
        "#{@start_time} - #{@end_time}, #{project_title}: #{@description}"
      end

      private

      # check a time against all loaded instances, verify that it doesn't
      # fall in the middle of any closed time records
      #
      def verify_start_time time

        # Check that there are currently
        # records on the day to iterate through
        dsym = self.class.date_symbol time
        return if not self.class.days_index[dsym]

        self.class.days_index[dsym].each do |record|

          next if record.end_time == :running

          if time < record.end_time
            raise ArgumentError, "Time conflict with existing record" if time_in_record? time, record
          end
        end
        true
      end

      def verify_end_time start_time, end_time

        # TODO: better check for :running conditions
        return true if end_time == :running

        raise ArgumentError, "End time earlier than start time" if end_time < start_time

        # Check that there are currently
        # records on the day to iterate through
        # necessary if self is not yet added to index
        dsym = self.class.date_symbol end_time
        return if not self.class.days_index[dsym]

        self.class.days_index[dsym].each do |record|

          if end_time > record.start_time

            # don't allow time to fall between existing start and end time
            raise ArgumentError, "Time conflict with existing record:" if time_in_record? end_time, record
          end
        end
        true
      end

      def time_in_record? time, record
        return false if record.end_time == :running
        time >= record.start_time && time <= record.end_time
      end

      # returns the last minute of the day
      def end_of_day time
        Time.new(time.year, time.month, time.day, 23, 59)
      end
    end
  end
end
