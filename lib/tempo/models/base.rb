module Tempo
  module Model

    class IdentityConflictError < Exception
    end

    class Base
      attr_reader :id

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

        # example: Tempo::Model::Animal -> tempo_animals.yaml
        def file
          FileRecord::Record.model_filename self
        end

        def save_to_file
          FileRecord::Record.save_model self
        end

        def read_from_file
          FileRecord::Record.read_model self
        end

        def method_missing meth, *args, &block

          if meth.to_s =~ /^find_by_(.+)$/
            run_find_by_method($1, *args, &block)

          elsif meth.to_s =~ /^sort_by_(.+)$/
            run_sort_by_method($1, *args, &block)
          else
            super
          end
        end

        def run_sort_by_method attribute, args=@index.clone, &block
          attr = "@#{attribute}".to_sym
          args.sort! { |a,b| a.instance_variable_get( attr ) <=> b.instance_variable_get( attr ) }
          return args unless block
          block.call args
        end

        def run_find_by_method attrs, *args, &block
          # Make an array of attribute names
          attrs = attrs.split('_and_')

          attrs_with_args = [attrs, args].transpose

          filtered = index.clone
          attrs_with_args.each do | kv |
            matches = find kv[0], kv[1]

            return matches if matches.empty?
            matches.each do |match|
              matches.delete match unless filtered.include? match
              filtered = matches
            end
          end
          filtered
        end

        # find by id should be exact, so we remove the array wrapper
        def find_by_id id
          matches = find "id", id
          match = matches[0]
        end

        # example: Tempo::Model.find("id", 1)
        #
        def find key, value
          key = "@#{key}".to_sym
          matches = []
          index.each do |i|
            stored_value = i.instance_variable_get( key )

            if stored_value.kind_of? String
              if value.kind_of? Regexp
                matches << i if value.match stored_value
              else
                matches << i if stored_value.downcase.include? value.to_s.downcase
              end

            elsif stored_value.kind_of? Integer
              matches << i if stored_value == value.to_i
            end
          end
          matches
        end

        def delete instance
          id = instance.id
          index.delete( instance )
          ids.delete( id )
        end
      end

      def initialize options={}
        id_candidate = options[:id]
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

          #val = val.to_s if val.kind_of? Time

          record[key] = val
        end
        record
      end

      def delete
        self.class.delete self
      end

      protected

      def self.add_to_index member
        @index ||= []
        @index << member
        @index.sort! { |a,b| a.id <=> b.id }
      end

      def self.add_id id
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
end

