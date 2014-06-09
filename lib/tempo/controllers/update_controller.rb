require 'chronic'

module Tempo
  module Controllers
    class Update < Tempo::Controllers::Base
      @projects = Model::Project
      @time_records = Model::TimeRecord

      class << self

        def parse(options, args)

          reassemble_the args

          return Views.project_assistance if Model::Project.index.empty?

          # Load last day, or specific day if options includes an on-date
          if options[:on]
            day = Time.parse options[:on]
            return Views.no_match_error( "valid timeframe", options[:from], false ) if day.nil?
            @time_records.load_day_record day, options
          else
            day = @time_records.load_last_day options
          end

          # Load the last record, or record by id if options includes an id
          if options[:id]
            record = @time_records.find_by_id( options[:id], day )
            return Views.no_match_error( "time record on #{day.strftime('%m/%d/%Y')}", "id = #{options[:id]}", false ) if !record
          else
            record = @time_records.index.last
            return Views.no_items( "time records on #{day.strftime('%m/%d/%Y')}", :error ) if ! record
          end

          # DELETE and existing record, no need to check for further updates
          if options[:delete]

            # If only record on the given day, delete the file
            if Tempo::Model::TimeRecord.ids(record.d_id).length == 1
              @time_records.delete_day_record record.d_id, options
            else
              record.delete
              @time_records.save_to_file options
            end

            Views.delete_time_record_view record

          else # check for flags and update one or all attributes

            # Update the START time of the record
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

            # Update the END time of the record
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

            # Update the PROJECT
            if options[:project]
              record.project = @projects.current.id
            end

            # Update the DESCRIPTION
            options[:description] = reassemble_the args
            record.description = options[:description] if options[:description] && !options[:description].empty?

            @time_records.save_to_file options
            Views.update_time_record_view record
          end
        end
      end #class << self
    end
  end
end
