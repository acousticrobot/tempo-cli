require 'yaml'

module Tempo
  module Model
    class Log < Tempo::Model::Base
      attr_accessor :start_time
      attr_reader :d_id

      class << self

        # Maintain arrays of unique ids for each day.
        # days are represented as symbols in the hash,
        # for example Jan 1, 2013 would be  :"130101"
        # id counter is managed through the private methods
        # increase_id_counter and next_id below
        #
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

        # all instances are saved in the index inherited from base.
        # Additionally, the days index organizes all instances into
        # arrays by day.  This is used for saving to file.
        #
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

        def records
          path = FileRecord::Record.log_dir( self )
          Dir[path + "/*.yaml"].sort!
        end

        def save_to_file
          FileRecord::Record.save_log( self )
        end


        def read_from_file time
          dsym = date_symbol time
          @days_index[ dsym ] = [] if not days_index.has_key? dsym
          FileRecord::Record.read_log( self, time )
        end

        # load all the records for a single day
        #
        def load_day_record time
          dsym = date_symbol time
          if not days_index.has_key? dsym
            @days_index[ dsym ] = []
            read_from_file time
          end
        end

        # load the records for each day from time 1 to time 2
        #
        def load_days_records time_1, time_2

          return if time_1.nil? || time_2.nil?

          days = ( time_2.to_date - time_1.to_date ).to_i
          return if days < 0

          (days + 1).times { |i| load_day_record( time_1.add_days( i ))}
        end

        # load the records for the most recently recorded day
        #
        def load_last_day
          reg = /(\d+)\.yaml/
          if records.last
            d_id = reg.match(records.last)[1] if records.last
            time = day_id_to_time d_id if d_id
            load_day_record time
            return time
          end
        end

        # takes and integer, and time or day_id
        # and returns the instance that matches both
        # the id and d_id
        def find_by_id id, time
          time = day_id time
          ids = find "id", id
          d_ids = find "d_id", time

          #return the first and only match in the union
          #of the arrays
          (ids & d_ids)[0]
        end

        # day_ids can be run through without change
        # Time will be converted into "YYYYmmdd"
        # ex: 1-1-2014 => "20140101"
        def day_id time
          if time.kind_of? String
            return time if time =~ /^\d{8}$/
          end
          raise ArgumentError, "Invalid Time" if not time.kind_of? Time
          time.strftime("%Y%m%d")
        end

        def day_id_to_time d_id
          time = Time.new(d_id[0..3].to_i, d_id[4..5].to_i, d_id[6..7].to_i)
        end

        def delete instance
          id = instance.id
          dsym = date_symbol instance.d_id

          index.delete instance
          days_index[dsym].delete instance
          @ids[dsym].delete id
        end
      end

      def initialize( options={} )
        @start_time = options.fetch(:start_time, Time.now )
        @start_time = Time.new(@start_time) if @start_time.kind_of? String

        self.class.load_day_record(@start_time)
        @d_id = self.class.day_id @start_time

        id_candidate = options[:id]
        if !id_candidate
          @id = self.class.next_id @start_time
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
