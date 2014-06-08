module Tempo
  module Controllers
    class Report < Tempo::Controllers::Base
      @projects = Model::Project
      @time_records = Model::TimeRecord

      class << self

        def report(options, args)

          return Tempo::Views.project_assistance if Tempo::Model::Project.index.empty?

          # A from flag has been supplied by the user
          # and possible a to flag as well,
          # so we return a period of day records
          #
          if options[:from] != "last record"
            from = Time.parse options[:from]
            return Views.no_match_error( "valid timeframe", options[:from], false ) if from.nil?

            to = Time.parse options[:to]
            return Views.no_match_error( "valid timeframe", options[:to], false ) if to.nil?

            @time_records.load_days_records from, to, options

            error_timeframe = " from #{from.strftime('%m/%d/%Y')} to #{to.strftime('%m/%d/%Y')}"

          # no arguments or flags have been supplied, so we return the
          # current day record
          #
          elsif args.empty?
            @time_records.load_last_day options

          # arguments have been supplied,
          # so we return the records for a single day
          #
          else
            time = reassemble_the args

            day = Time.parse time
            return Views.no_match_error( "valid timeframe", time, false ) if day.nil?

            @time_records.load_day_record day, options

            error_timeframe = " on #{day.strftime('%m/%d/%Y')}"
          end

          return Views.no_items( "time records#{error_timeframe}", :error ) if @time_records.index.empty?

          Views.report_records_view
        end
      end #class << self
    end
  end
end
