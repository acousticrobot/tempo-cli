module Tempo

  # Takes an array of source strings
  # and filters them down to the ones
  # that match positively against every
  # member of the matches array
  def self.fuzzy_match(haystack, matches)
    results = []
    matches.each do |m|
      reg = /#{m}/
      haystack.each do |h|
        results << h if reg.match h
      end
      haystack = results
      results = []
    end
    haystack
  end
end



