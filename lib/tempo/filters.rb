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

  # When args are sent in without quotes, they
  # are broken into an array, and the first block
  # will be passed to a flag if present. Here we
  # reassemble the string, and add value stored in
  # a flag in the front. Pass flags in as an array,
  # if only one flag is used with the command.

  def self.reassemble_free_args(args,flags=[])
    assembled = ""
    flags.each do |flag|
      args.unshift flag if flag
    end
    args.each { |a| assembled += " #{a}" }
    assembled.strip!
  end
end



