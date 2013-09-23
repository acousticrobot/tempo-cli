require 'chronic'

module Tempo
  module Controllers
    class Start < Tempo::Controllers::Base
      @projects = Model::Project

      class << self

        def start_timer( options, args )
          request = reassemble_the args

          if not request
            time_in = Time.new()
          else
            time_in = Chronic.parse request
          end

          Tempo::Views.no_match( "valid timeframe", request, false ) if not time_in

          params = { start_time: time_in }
          params[:description] = options[:description]

          if options[:end]
            time_out = Chronic.parse options[:end]
            Tempo::Views.no_match( "valid timeframe", request, false ) if not time_out
            params[:end_time] = time_out
          end

          record = Tempo::Model::TimeRecord.new(params)
          Tempo::Model::TimeRecord.save_to_file

          Tempo::Views.time_record_view( record, {new_record: true} )

        end

      end #class << self
    end
  end
end
