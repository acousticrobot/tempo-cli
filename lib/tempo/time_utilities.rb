# see also
# http://rtmatheson.com/2011/12/rounding-time-to-the-closest-hour-in-ruby/

class Time

  #default to whole minutes
  def round(options={})
    seconds = 60
    Time.at((self.to_f / seconds).round * seconds)
  end

  def add_days(days)
    t = self + days * 86400 # 24 * 60 * 60
  end
end
