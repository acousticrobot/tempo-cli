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

  # Gli default behavior: When args are sent in a
  # command without quotes, they are broken into an array,
  # and the first block is passed to a flag if present.
  # Here we reassemble the string, and add value stored in
  # a flag in the front.

  def self.reassemble_the( args, flag=nil )
    assembled = ""
    args.unshift flag if flag
    args.each { |a| assembled += " #{a}" }
    assembled.strip!
  end
end



