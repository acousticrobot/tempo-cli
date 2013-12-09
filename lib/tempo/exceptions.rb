module Tempo

  # Reporter raises and error when view records of unknown format
  class InvalidViewRecordError < Exception
  end

  # This error is raised when an existing time period conflicts with a time or time period
  # All parameters are optional, and will be build into the error string if supplied
  #
  # Expected parameters are Time objects, but nil or strings will be handled as well
  #
  # examples:
  #
  # ()                => "time conflicts with existing record"
  # (<8:00>, <10:00>) => "time conflicts with existing record: 8:00 - 10:00"
  # (<8:00>, <10:00>, <9:00>) => "time <9:00> conflicts with existing record: 8:00 - 10:00"
  # (<8:00>, <10:00>, <9:00>, <9:30>) => "time <9:00 - 9:30> conflicts with existing record: 8:00 - 10:00"
  # (<8:00>, :running) => "time conflicts with existing record: 8:00 - running"
  #
  class TimeConflictError < ArgumentError

    def initialize( start_time=nil, end_time=nil, target_start_time=nil, target_end_time=nil )

      @end_time = (end_time.kind_of? Time) ? end_time.strftime('%H:%M') : end_time.to_s
      @end_time = " - #{@end_time}" if !@end_time.empty?
      @existing = (start_time.kind_of? Time) ? ": #{start_time.strftime('%H:%M')}#{@end_time}" : start_time.to_s

      @target_end_time = (target_end_time.kind_of? Time) ? "#{target_end_time.strftime('%H:%M')}" : target_end_time.to_s
      @target_end_time = " - #{@target_end_time}" if !@target_end_time.empty?
      @target = (target_start_time.kind_of? Time) ? "<#{target_start_time.strftime('%H:%M')}#{@target_end_time}> " : ""

      @message = "time #{@target}conflicts with existing record#{@existing}"
    end

    def to_s
      @message
    end
  end
end