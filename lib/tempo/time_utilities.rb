# http://rtmatheson.com/2011/12/rounding-time-to-the-closest-hour-in-ruby/

class Time
  def round(options={})
    seconds = 60
    Time.at((self.to_f / seconds).round * seconds)
  end
end