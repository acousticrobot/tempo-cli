require 'chronic'

module Tempo
  module Controllers
    class Update < Tempo::Controllers::Base
      @projects = Model::Project
      @time_records = Model::TimeRecord

      class << self

        def parse options, args

          reassemble_the args

          return Views.project_assistance if Model::Project.index.empty?

          if options[:on]
            day = Time.parse options[:on]
            return Views.no_match_error( "valid timeframe", options[:from], false ) if day.nil?
            @time_records.load_day_record day
          else
            day = @time_records.load_last_day
          end

          if options[:id]
            record = @time_records.find_by_id( options[:id], day )
            return Views.no_match_error( "time record on #{day.strftime('%m/%d/%Y')}", "id = #{options[:id]}", false ) if !record
          else
            record = @time_records.index.last
            return Views.no_items( "time records on #{day.strftime('%m/%d/%Y')}", :error ) if ! record
          end


          if options[:delete]
            record.delete
            @time_records.save_to_file
            Views.delete_time_record_view record

          else
            if options[:start]
              start_time = Time.parse options[:start]
              return Views.no_match_error( "valid timeframe", options[:at], false ) if start_time.nil?

              # TODO: add "today " to start time and try again if not valid
              if record.valid_start_time? start_time
                record.start_time = start_time
              else
                return Views::ViewRecords::Message.new "cannot change start time to #{start_time.strftime('%H:%M')}", category: :error
              end
            end

            if options[:end]
              end_time = Time.parse options[:end]
              return Views.no_match_error( "valid timeframe", options[:at], false ) if end_time.nil?

              # TODO: add "today " to end time and try again if not valid
              if record.valid_end_time? end_time
                record.end_time = end_time
              else
                return Views::ViewRecords::Message.new "cannot change end time to #{end_time.strftime('%H:%M')}", category: :error
              end
            end

            if options[:project]
              record.project = @projects.current.id
            end

            options[:description] = reassemble_the args
            record.description = options[:description] if options[:description] && !options[:description].empty?

            @time_records.save_to_file
            Views.update_time_record_view record
          end
        end
      end #class << self
    end
  end
end
