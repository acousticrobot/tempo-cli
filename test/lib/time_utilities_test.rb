require "test_helper"

describe Time do

  it "returns nil on invalid information" do
    Time.parse("t").must_equal nil
  end

  it "rounds to the nearest whole minute" do
    Time.new(2015,6,18,11,33,25).round.must_equal Time.new(2015,6,18,11,33)
    Time.new(2015,6,18,11,33,45).round.must_equal Time.new(2015,6,18,11,34)
  end

  it "adds days to time" do
    Time.new(2015,6,18,11,33,45).add_days(5).must_equal Time.new(2015,6,23,11,33,45)
  end

  it "moves time to a different day" do
    Time.new(2015,6,18,11,33,45).on_date(Time.new(2015,6,23)).must_equal Time.new(2015,6,23,11,33,45)
  end

  it "verifies two times occur on the same day" do
    Time.new(2015,6,18,11,33,45).same_day?(Time.new(2015,6,18,16,22,30)).must_equal true
    Time.new(2015,6,18,11,33,45).same_day?(Time.new(2015,6,17,16,22,30)).must_equal false
  end
end
