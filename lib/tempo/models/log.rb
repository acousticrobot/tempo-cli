require "pry"


module Tempo
  module Model
    class Log < Tempo::Model::Base
      attr_accessor :start_time

      class << self

        # Maintain arrays of unique ids for each day.
        # days are represented as symbols in the hash,
        # for example Jan 1, 2013 would be  :"130101" => 4
        # and counter
        def id_counter time
          tsym = time_symbol time
          @id_counter = {} unless @id_counter.kind_of? Hash
          @id_counter[ tsym ] ||= 1
        end

        def ids time
          tsym = time_symbol time
          @ids = {} unless @ids.kind_of? Hash
          @ids[tsym] ||= []
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
          FileRecord::Record.read_log( self, time )
        end
      end

      def initialize( params={} )
        # for time logs:
        # @message, @project, and @end_time

        @start_time = params.fetch(:start_time, Time.now )
        @start_time = Time.new(@start_time) if @start_time.kind_of? String

        id_candidate = params[:id]
        if !id_candidate
          @id = self.class.next_id @start_time
        elsif self.class.ids( @start_time ).include? id_candidate
          raise IdentityConflictError, "Id #{id_candidate} already exists"
        else
          @id = id_candidate
        end

        self.class.add_id @start_time, @id
        self.class.add_to_index self
      end

      protected

      class << self

        def add_to_index member
          @index = {} unless @index.kind_of? Hash
          tsym = time_symbol member.start_time
          @index[tsym] ||= []
          @index[tsym] << member
          @index[tsym].sort! { |a,b| a.start_time <=> b.start_time }
        end

        def add_id time, id
          tsym = time_symbol time
          @ids = {} unless @ids.kind_of? Hash
          @ids[tsym] ||= []
          @ids[tsym] << id
          @ids[tsym].sort!
        end

        def date_id time
          raise ArgumentError if not time.kind_of? Time
          time.strftime("%Y%m%d")
        end

        def time_symbol time
          date_id( time ).to_sym
        end

        def increase_id_counter time
          tsym = time_symbol time
          @id_counter = {} unless @id_counter.kind_of? Hash
          @id_counter[ tsym ] ||= 0
          @id_counter[ tsym ] = @id_counter[ tsym ].next
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
