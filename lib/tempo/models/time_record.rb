# Time Record is an extension of the Log Model,
# it adds an end time, and verifies that no records overlap
# in their time periods. Additionally, one, and only on record
# can be running at any given time, and it can only be the most
# recent record.

module Tempo
  module Model

    class TimeRecord < Tempo::Model::Log
      attr_accessor :project, :description
      attr_reader :start_time, :end_time, :tags

      class << self

        # Only one record can be running at any given time. This record
        # is the class current, and has and end time of :running
        #
        def current
          return @current if @current && @current.end_time == :running
          @current = nil
        end

        def current=instance
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
        # super handles start_time, not end time
        options[:start_time] ||= Time.now
        @end_time = options.fetch :end_time, :running

        if options[:round_time]
          options[:start_time] = options[:start_time].round
          @end_time = @end_time.round
        end

        verify_times options[:start_time], @end_time

        super options

        project = options.fetch :project, Tempo::Model::Project.current
        @project = project.kind_of?(Integer) ? project : project.id

        @tags = []
        tag options.fetch(:tags, [])

        leave_only_one_running
      end

      def start_time=time
        raise ArgumentError if !time.kind_of? Time
        if @end_time != :running
          @start_time = time if verify_times time, @end_time
        else
          @start_time = time if verify_start_time time
        end
      end

      # end time cannot be set to :running, only to a
      # valid Time object
      # Use running! to restart a time record
      #
      def end_time=time
        raise ArgumentError if !time.kind_of? Time
        @end_time = time if verify_times self.start_time, time
      end

      # method for updating both times at once, necessary if it would
      # cause a conflict to do them individually
      #
      def update_times(start_time, end_time)
        raise ArgumentError if !start_time.kind_of? Time
        raise ArgumentError if !end_time.kind_of? Time
        verify_times start_time, end_time
        @start_time = start_time
        @end_time = end_time
        leave_only_one_running
      end

      # Public method to access verify start time,
      # determine if an error will be raised
      #
      def valid_start_time?(time)
        return false if !time.kind_of? Time
        begin
          if @end_time != :running
            verify_times time, @end_time
          else
            verify_start_time time
          end
        rescue ArgumentError => e
          return false
        end
        true
      end

      # Public method to access verify end time,
      # determine if an error will be raised
      #
      def valid_end_time?(time)
        return false if !time.kind_of? Time
        begin
          verify_times self.start_time, time
        rescue ArgumentError => e
          return false
        end
        true
      end

      # Returns the next record in time from the current record
      # Remember, only records loaded from files will be available
      # to compare against, so it is important to use the following
      # methods defined in Log first to assure accuracy:
      #   * load_day_record
      #   * load_days_records
      #   * load_last_day
      #
      # uses start_time if end time is :running
      #
      def next_record
        next_one = nil
        end_time = ( @end_time.kind_of? Time ) ? @end_time : @start_time
        self.class.index.each do |record|
          next if record == self
          if next_one == nil && record.start_time >= end_time
            next_one = record
          elsif record.start_time >= end_time && record.start_time < next_one.start_time
            next_one = record
          end
        end
        next_one
      end

      def project_title
        Project.find_by_id( @project ).title if @project
      end

      def duration
        if @end_time.kind_of? Time
          end_time = @end_time
        else
          end_time = Time.now().round
        end
        end_time.to_i - @start_time.to_i
      end

      def running?
        @end_time == :running
      end

      def running!
        raise "only the most recent record can be reopened" unless self == self.class.last_record
        @end_time = :running
      end

      def freeze_dry
        record = super
        record[:project_title] = project_title
        record
      end

      def tag(tags)
        return unless tags and tags.kind_of? Array
        tags.each do |tag|
          tag.split.each {|t| @tags << t if ! @tags.include? t }
        end
        @tags.sort!
      end

      def untag(tags)
        return unless tags and tags.kind_of? Array
        tags.each do |tag|
          tag.split.each {|t| @tags.delete t }
        end
      end

      def to_s
        "#{@start_time} - #{@end_time}, #{project_title}: #{@description}"
      end

      private

      # close current at the end time, or on the last minute
      # of the day if end time is another day
      #
      def self.close_current(end_time)
        if end_time.day > current.start_time.day
          out = end_of_day current.start_time
          current.end_time = out
        else
          current.end_time = end_time
        end
      end

      # If the current project end_time is :running, we
      # need to update the class running record to the most
      # recent record that is running. We also need to close out
      # all other records at the start time of the next record,
      # or the end of the day if it is the last record on that day.
      #
      # If the current project has an end_time, then we
      # close any previous running record.
      #
      def leave_only_one_running

        if running?

          nxt_rcrd = next_record

          # Nothing running, no newer records, make this one current
          if self.class.current.nil? && nxt_rcrd.nil?
            self.class.current = self

          # This is the newest record, close out the running record
          elsif self.class.current && nxt_rcrd.nil?
            self.class.close_current @start_time
            self.class.current = self

          # newer records exits, close out on the next record start
          # date, or end of day if next record is on another day.
          #
          # ? Do we care about the current record ?
          else
            #current = self.class.current

            # # more recent running entries exist, close this record
            # if current.start_time > @start_time
            #   if current.start_time.day > @start_time.day
            #     out = self.class.end_of_day @start_time
            #     @end_time = out
            #   else
            #     @end_time = current.start_time
            #   end


            if nxt_rcrd.start_time.day == @start_time.day
              @end_time = nxt_rcrd.start_time
            else
              @end_time = self.class.end_of_day @start_time
            end
          end

        # Not running, but we still need to close out any earlier running timerecords
        else
          if self.class.current
             if self.class.current.start_time < @start_time
               self.class.close_current @start_time
             end
          end
        end
      end

      # check a time against all loaded instances, verify that it doesn't
      # fall in the middle of any closed time records
      #
      def verify_start_time(time)

        # Check that there are currently
        # records on the day to iterate through
        dsym = self.class.date_symbol time
        return true if not self.class.days_index[dsym]

        self.class.days_index[dsym].each do |record|

          next if record.end_time == :running
          next if record == self
          if time < record.end_time
            raise Tempo::TimeConflictError.new( record.start_time, record.end_time, time ) if time_in_record? time, record
          end
        end
        true
      end

      # We never have an end time without a start time
      # so this is also the equivalent of a verify_end_time method
      # This method returns true for any valid start time, and an
      # end time of :running. This condition, (currently only possible from init)
      # requires a second check to close out all but the most recent time entry.
      #
      def verify_times(start_time, end_time)

        verify_start_time start_time

        # TODO: a better check for :running conditions
        return true if end_time == :running

        raise Tempo::EndTimeError.new(start_time, end_time) if end_time < start_time

        dsym = self.class.date_symbol end_time
        start_dsym = self.class.date_symbol start_time

        raise Tempo::DifferentDaysError.new(start_time, end_time) if dsym != start_dsym

        # this is necessary if this is the first record
        # for the day and self is not yet added to index
        return if not self.class.days_index[dsym]

        self.class.days_index[dsym].each do |record|
          next if record == self
          raise Tempo::TimeConflictError.new( record.start_time, record.end_time, start_time, end_time ) if time_span_intersects_record? start_time, end_time, record
        end
        true
      end

      # this is used for both start time and end times,
      # so it will return false if the time is :running
      #
      # It will return true if it is exactly the record start or end time
      #
      def time_in_record?(time, record)
        return false if record.end_time == :running
        time >= record.start_time && time <= record.end_time
      end

      # All true conditions should be used to raise errors.
      # Returns false is when sharing a single end and start point (a valid state).
      # It does not invalidate a time span earlier than the record with a :running end time,
      # this condition must be accounted for separately.
      # It assumes a valid start and end time.
      #
      def time_span_intersects_record?(start_time, end_time, record)
        if record.end_time == :running
          return true if start_time <= record.start_time && end_time > record.start_time
          return false
        end
        return false if start_time >= record.end_time
        return true if start_time >= record.start_time && start_time < record.end_time
        return false if record.end_time == :running
        return true if end_time > record.start_time
        return false
      end

      # returns the last minute of the day
      #
      def self.end_of_day(time)
        Time.new(time.year, time.month, time.day, 23, 59)
      end
    end
  end
end
