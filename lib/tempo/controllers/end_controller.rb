require 'chronic'

module Tempo
  module Controllers
    class End < Tempo::Controllers::Base
      @projects = Model::Project
      @time_records = Model::TimeRecord

      class << self

        def end_timer options, args

          if not options[:at]
            time_out = Time.new()
          else
            begin
              time_out = Chronic.parse options[:at]
            rescue
              time_out = nil
            end
          end

          Tempo::Views.no_match( "valid timeframe", options[:at], false ) if not time_out

          params = { end_time: time_out }
          params[:description] = reassemble_the args

          @time_records.load_last_day
          record = @time_records.current

          Tempo::Views.no_items( "running time records", true ) if ! record

          record.end_time = time_out
          record.description = params[:description] if params[:description]
          @time_records.save_to_file

          Tempo::Views.end_time_record_view record

        end

      end #class << self
    end
  end
end
