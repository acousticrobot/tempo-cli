require "pry"

# find by id will need to include a date object ( find_by_date_and_id )

module Tempo
  module Model
    class Log < Tempo::Model::Base
      attr_accessor :start_time
      attr_reader :d_id

      class << self

        # Maintain arrays of unique ids for each day.
        # days are represented as symbols in the hash,
        # for example Jan 1, 2013 would be  :"130101" => 4
        # and counter
        def id_counter time
          dsym = date_symbol time
          @id_counter = {} unless @id_counter.kind_of? Hash
          @id_counter[ dsym ] ||= 1
        end

        def ids time
          dsym = date_symbol time
          @ids = {} unless @ids.kind_of? Hash
          @ids[dsym] ||= []
        end

        # all instances are saved in the index inherited from base
        # additionally, the days index organizes all instances into
        # arrays by day.  This is used for saving to file.
        def days_index
          @days_index = {} unless @days_index.kind_of? Hash
          @days_index
        end

        def file time
          FileRecord::Record.log_filename( self, time )
        end

        def dir
          FileRecord::Record.log_dirname( self )
        end

        def save_to_file
          FileRecord::Record.save_log( self )
        end

        def read_from_file time
          dsym = date_symbol time
          @days_index[ dsym ] = [] if not days_index.has_key? dsym
          FileRecord::Record.read_log( self, time )
        end

        def load_days_record time
          dsym = date_symbol time
          if not days_index.has_key? dsym
            @days_index[ dsym ] = []
            read_from_file time
          end
        end

        def find_by_id id, time
          time = day_id time
          ids = find "id", id
          d_ids = find "d_id", time
          ids & d_ids
        end

        # day_ids can be run through without change
        # Time will be converted into "YYYYmmdd"
        # ex: 1-1-2014 => "20140101"
        def day_id time
          if time.kind_of? String
            return time if time =~ /^\d{8}$/
          end
          raise ArgumentError if not time.kind_of? Time
          time.strftime("%Y%m%d")
        end

        def delete instance
          id = instance.id
          dsym = date_symbol instance.d_id

          index.delete( instance )
          @ids[dsym].delete id
          # ids( instance.start_time ) delete id
        end
      end

      def initialize( params={} )
        @start_time = params.fetch(:start_time, Time.now )
        @start_time = Time.new(@start_time) if @start_time.kind_of? String
        self.class.load_days_record(@start_time)

        id_candidate = params[:id]
        if !id_candidate
          @id = self.class.next_id @start_time
          @d_id = self.class.day_id @start_time
        elsif self.class.ids( @start_time ).include? id_candidate
          raise IdentityConflictError, "Id #{id_candidate} already exists"
        else
          @id = id_candidate
        end

        self.class.add_id @start_time, @id
        self.class.add_to_index self
        self.class.add_to_days_index self
      end

      def freeze_dry
        record = super
        record.delete(:d_id)
        record
      end

      protected

      class << self

        def add_to_days_index member
          @days_index = {} unless @days_index.kind_of? Hash
          dsym = date_symbol member.start_time
          @days_index[dsym] ||= []
          @days_index[dsym] << member
          @days_index[dsym].sort! { |a,b| a.start_time <=> b.start_time }
        end

        def add_id time, id
          dsym = date_symbol time
          @ids = {} unless @ids.kind_of? Hash
          @ids[dsym] ||= []
          @ids[dsym] << id
          @ids[dsym].sort!
        end

        def date_symbol time
          day_id( time ).to_sym
        end

        def increase_id_counter time
          dsym = date_symbol time
          @id_counter = {} unless @id_counter.kind_of? Hash
          @id_counter[ dsym ] ||= 0
          @id_counter[ dsym ] = @id_counter[ dsym ].next
        end

        def next_id time
          while ids(time).include? id_counter time
            increase_id_counter time
          end
          id_counter time
        end
      end
    end
  end
end
