require 'chronic'
# see also
# http://rtmatheson.com/2011/12/rounding-time-to-the-closest-hour-in-ruby/

class Time

  class << self
    def parse time
      # Chronic will usually return nil when unable to parse time
      # it throws an error, on 't' and a few other string, so we
      # capture these here an assure that nil is returned
      begin
        chron = Chronic.parse time
        chron.round
      rescue Exception => e
        return nil
      end
    end
  end

  #default to whole minutes
  def round options={}
    seconds = 60
    Time.at((self.to_f / seconds).round * seconds)
  end

  def add_days days
    t = self + days * 86400 # 24 * 60 * 60
  end
end
