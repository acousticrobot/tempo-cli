module Tempo

  class IdentityConflictError < Exception
  end

  class Model
    attr_accessor :id

    class << self

      # Maintain an array of unique ids for the class.
      # Initialize new members with the next numberical id
      # Ids can be assigned on init (for the purpose of reading
      # in records of previous instances). An error will
      # be raised if there is already an instance with that
      # id.
      def id_counter
        @id_counter ||= 1
      end

      def ids
        @ids ||= []
      end

      def index
        @index ||= []
      end
    end

    def initialize( params={} )
      id_candidate = params[:id]
      if !id_candidate
        @id = self.class.next_id
      elsif self.class.ids.include? id_candidate
        raise IdentityConflictError, "Id #{id_candidate} already exists"
      else
        @id = id_candidate
      end
      self.class.add_id @id
      self.class.add_to_index self
    end

    # record the state of all instance variables as a hash
    def freeze_dry
      record = {}
      state = instance_variables
      state.each do |attr|
        key = attr[1..-1].to_sym
        val = instance_variable_get attr
        record[key] = val
      end
      record
    end

    protected

    def self.add_to_index( member)
      @index ||= []
      @index << member
    end

    def self.add_id( id )
      @ids ||=[]
      @ids << id
      @ids.sort!
    end

    def self.increase_id_counter
      @id_counter ||= 0
      @id_counter = @id_counter.next
    end

    def self.next_id
      while ids.include? id_counter
        increase_id_counter
      end
      id_counter
    end
  end
end