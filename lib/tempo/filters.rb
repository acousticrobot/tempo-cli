module Tempo

  # Takes an array of source strings
  # and filters them down to the ones
  # that match positively against every
  # member of the matches array

  def self.fuzzy_match( haystack, matches, attribute="id" )

    matches = [matches] unless matches.is_a? Array

    if haystack.is_a? Array
      fuzzy_array_match( haystack, matches )

    elsif haystack.superclass == Tempo::Model
      fuzzy_model_match( haystack, matches, attribute )
    end
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

  private

  # TODO: escape regex characters ., (), etc.
  def self.match_to_regex( match )
    /#{match}/
  end

  def self.fuzzy_array_match( haystack, matches )
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

  def self.fuzzy_model_match( haystack, matches, attribute )
    attribute = "@#{attribute}".to_sym
    contenders = haystack.index
    results = []
    matches.each do |m|
      reg = match_to_regex m
      contenders.each do |c|
        results << c if reg.match c.instance_variable_get(attribute)
      end
      contenders = results
      results = []
    end
    contenders
  end
end



