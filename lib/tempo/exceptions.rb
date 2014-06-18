module Tempo

  # Reporter raises and error when view records of unknown format
  class InvalidViewRecordError < Exception
  end

  # This error is raised when an existing time period conflicts with a time or time period
  # All parameters are optional, and will be build into the error string if supplied
  #
  # Expected parameters are Time objects, but nil or strings will be handled as well.
  #
  # If start time is a Time object, the date will be added to the message.
  #
  # examples:
  #
  # ()                => "time conflicts with existing record"
  # (<8:00>, <10:00>) => "time conflicts with existing record: 8:00 - 10:00"
  # (<8:00>, <10:00>, <9:00>) => "time <9:00> conflicts with existing record: 8:00 - 10:00"
  # (<8:00>, <10:00>, <9:00>, <9:30>) => "time <9:00 - 9:30> conflicts with existing record: 8:00 - 10:00"
  # (<8:00>, :running) => "time conflicts with existing record: 8:00 - running"
  #
  # (<2015-09-23 11:50:00 -0400>,...) "... on Sept 23, 2015"

  class TimeConflictError < ArgumentError

    def initialize(start_time=nil, end_time=nil, target_start_time=nil, target_end_time=nil)
      @end_time = (end_time.kind_of? Time) ? end_time.strftime('%H:%M') : end_time.to_s
      @end_time = " - #{@end_time}" if !@end_time.empty?
      @existing = (start_time.kind_of? Time) ? ": #{start_time.strftime('%H:%M')}#{@end_time}" : start_time.to_s

      @target_end_time = (target_end_time.kind_of? Time) ? "#{target_end_time.strftime('%H:%M')}" : target_end_time.to_s
      @target_end_time = " - #{@target_end_time}" if !@target_end_time.empty?
      @target = (target_start_time.kind_of? Time) ? "<#{target_start_time.strftime('%H:%M')}#{@target_end_time}> " : ""

      @on_day = (start_time.kind_of? Time) ? " on #{start_time.strftime('%b %d, %Y')}" : ""
      @message = "time #{@target}conflicts with existing record#{@existing}#{@on_day}"
    end

    def to_s
      @message
    end
  end

  # Raise when the end time is less than the start time
  # start_time and end_time should be Time objects
  class EndTimeError < ArgumentError

    def initialize(start_time, end_time)
      @start_time = (start_time.kind_of? Time) ? start_time.strftime('%H:%M') : start_time.to_s
      @end_time = (end_time.kind_of? Time) ? end_time.strftime('%H:%M') : end_time.to_s
      @on_day = (start_time.kind_of? Time) ? "on #{start_time.strftime('%b %d, %Y')}" : ""

      @message = "End time #{@end_time} must be greater than start time #{@start_time} #{@on_day}"
    end

    def to_s
      @message
    end
  end

  class DifferentDaysError < ArgumentError

    def initialize(start_time, end_time)
      @start_time = (start_time.kind_of? Time) ? start_time.strftime('%H:%M on %b %d, %Y') : start_time.to_s
      @end_time = (end_time.kind_of? Time) ? end_time.strftime('%H:%M on %b %d, %Y') : end_time.to_s
      @message = "End time must be on the same day as start time: #{start_time} : #{end_time}"
    end

    def to_s
      @message
    end
  end
end
