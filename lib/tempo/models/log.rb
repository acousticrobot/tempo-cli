require 'yaml'

# Log extends base by allowing models to be associated with a time instance.
# Ids are only unique by day, and each model also has a day id. Together these
# two ids assure uniquness. When saved, each day is recorded as it's own file.

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
        def id_counter(time)
          dsym = date_symbol time
          @id_counter = {} unless @id_counter.kind_of? Hash
          @id_counter[ dsym ] ||= 1
        end

        # Returns an array of ids for the given day
        def ids(time)
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

        # Passthrough function, returns the log filename for a given date
        #
        def file(time)
          FileRecord::FileUtility.new(self, {time: time}).filename
        end

        # Returns the immediate directory for the log
        # Tempo::Model::MessageLog => tempo_message_logs
        def dir
          FileRecord::FileUtility.new(self).log_directory
        end

        # Load all records from a directory into an array
        # send alternate directory through options
        def records(options={})
          FileRecord::FileUtility.new(self, options).log_records
        end

        # returns the loaded record with the latest start time
        # Only loads records if options[:load] is true,
        # otherwise assumes records are already loaded
        def last_record(options={})
          load_last_day(options) if options[:load]
          sort_by_start_time.last
        end

        # send alternate directory through options
        def save_to_file(options={})
          FileRecord::Record.save_log(self, options)
        end

        # send alternate directory through options
        def read_from_file(time, options={})
          dsym = date_symbol time
          @days_index[ dsym ] = [] if not days_index.has_key? dsym
          FileRecord::Record.read_log(self, time, options)
        end

        # load all the records for a single day
        #
        def load_day_record(time, options={})
          dsym = date_symbol time
          if not days_index.has_key? dsym
            @days_index[ dsym ] = []
            read_from_file time, options
          end
        end

        # load the records for each day from time 1 to time 2
        #
        def load_days_records(time_1, time_2, options={})

          return if time_1.nil? || time_2.nil?

          days = (time_2.to_date - time_1.to_date).to_i
          return if days < 0

          (days + 1).times { |i| load_day_record(time_1.add_days(i), options)}
        end

        # Return a Time object for the last record's date
        def last_day(options={})
          reg = /(\d+)\.yaml/
          recs = records options
          if recs.last
            d_id = reg.match(recs.last)[1]
            time = day_id_to_time d_id if d_id
            return time
          end
          return nil
        end

        # load the records for the most recently recorded day
        #
        def load_last_day(options={})
          time = last_day options
          return nil unless time
          load_day_record time, options
          return time
        end

        # delete the file for a single day
        # this is necessary for removing a single entry on a day
        # since updates will skip over days with no entries
        #
        def delete_day_record(time, options={})
          options[:time] = time
          options[:destroy] = true
          FileRecord::FileUtility.new(self, options).file_path
        end

        # Used when cleaning (and testing) records
        def clear_all
          @ids = {}
          @index = []
          @days_index = {}
          @id_counter = {}
          @current = nil
        end

        # takes and integer, and time or day_id
        # and returns the instance that matches both
        # the id and d_id
        def find_by_id(id, time)
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
        def day_id(time)
          return time if time.to_s =~ /^\d{8}$/

          raise ArgumentError, "Invalid Time" if not time.kind_of? Time
          time.strftime("%Y%m%d")
        end

        def day_id_to_time(d_id)
          time = Time.new(d_id[0..3].to_i, d_id[4..5].to_i, d_id[6..7].to_i)
        end

        def delete(instance)
          id = instance.id
          dsym = date_symbol instance.d_id

          index.delete instance
          days_index[dsym].delete instance
          @ids[dsym].delete id
        end
      end # class << self

      def initialize(options={})
        @start_time = options.fetch(:start_time, Time.now)
        @start_time = Time.new(@start_time) if @start_time.kind_of? String

        self.class.load_day_record(@start_time)
        @d_id = self.class.day_id @start_time

        id_candidate = options[:id]
        if !id_candidate
          @id = self.class.next_id @start_time
        elsif self.class.ids(@start_time).include? id_candidate
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

        def add_to_days_index(member)
          @days_index = {} unless @days_index.kind_of? Hash
          dsym = date_symbol member.start_time
          @days_index[dsym] ||= []
          @days_index[dsym] << member
          @days_index[dsym].sort! { |a,b| a.start_time <=> b.start_time }
        end

        def add_id(time, id)
          dsym = date_symbol time
          @ids = {} unless @ids.kind_of? Hash
          @ids[dsym] ||= []
          @ids[dsym] << id
          @ids[dsym].sort!
        end

        def date_symbol(time)
          day_id(time).to_sym
        end

        def increase_id_counter(time)
          dsym = date_symbol time
          @id_counter = {} unless @id_counter.kind_of? Hash
          @id_counter[ dsym ] ||= 0
          @id_counter[ dsym ] = @id_counter[ dsym ].next
        end

        def next_id(time)
          while ids(time).include? id_counter time
            increase_id_counter time
          end
          id_counter time
        end
      end
    end
  end
end
