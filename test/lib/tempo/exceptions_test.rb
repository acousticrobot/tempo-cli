require "test_helper"

describe Tempo::TimeConflictError do

  before(:each) do
    @start_time = Time.new(2014, 1, 2, 7, 15)
    @end_time = Time.new(2104, 1, 2, 9, 15)
    @target_start_time = Time.new(2104, 1, 2, 8, 15)
    @target_end_time = Time.new(2104, 1, 2, 8, 45)
  end

  it "can create a message with a target duration" do
    @exception = Tempo::TimeConflictError.new @start_time, @end_time, @target_start_time, @target_end_time
    @exception.to_s.must_equal "time <08:15 - 08:45> conflicts with existing record: 07:15 - 09:15 on Jan 02, 2014"
  end

  it "can create a message with a target time" do
    @exception = Tempo::TimeConflictError.new @start_time, @end_time, @target_start_time
    @exception.to_s.must_equal "time <08:15> conflicts with existing record: 07:15 - 09:15 on Jan 02, 2014"
  end

  it "can create a message without a target time" do
    @exception = Tempo::TimeConflictError.new @start_time, @end_time
    @exception.to_s.must_equal "time conflicts with existing record: 07:15 - 09:15 on Jan 02, 2014"
  end

  it "can handle running time entries" do
    @exception = Tempo::TimeConflictError.new @start_time, :running, @target_start_time
    @exception.to_s.must_equal "time <08:15> conflicts with existing record: 07:15 - running on Jan 02, 2014"
  end
end
