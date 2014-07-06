require 'chronic'

module Tempo
  module Controllers
    class Start < Tempo::Controllers::Base
      @projects = Model::Project
      @time_records = Model::TimeRecord

      class << self

        def start_timer(options, args)

          return Views.project_assistance if Model::Project.index.empty?

          if not options[:at]
            start_time = Time.new()
          else
            start_time = Time.parse options[:at]
          end

          return Views.no_match_error( "valid timeframe", options[:at], false ) if start_time.nil?

          if start_time > Time.new()
            Views.warning("WARNING: logging time in the future may cause trouble maintaining running records")
          end

          opts = { start_time: start_time }
          opts[:description] = reassemble_the args

          if options[:end]
            end_time = Time.parse options[:end]
            return Views.no_match_error( "valid timeframe", options[:end], false ) if end_time.nil?
            opts[:end_time] = end_time
          end

          load_records(start_time, options)

          # Restart the last time record
          if options[:resume]
            last_record = @time_records.last_record

            return Views.error("cannot resume last time record when it is still running") if last_record.running?

            opts[:description] = last_record.description

            # we use the last used project, but don't save it as current
            # in case a different project has been checked out.
            @projects.current = @projects.find_by_id(last_record.project)

            record = @time_records.new(opts)

          # Add a new time record
          else
            record = @time_records.new(opts)
          end

          @time_records.save_to_file options

          Views.start_time_record_view record
        end

        private

        # Load all records necessary to start a new record
        def load_records(start_time, options)

          last_day = @time_records.last_day(options)

          # No records exits yet
          return if !last_day

          if start_time.same_day?(last_day) || start_time > last_day
            @time_records.load_last_day options
          else
            @time_records.load_days_records(start_time, last_day, options)
          end
        end

      end #class << self

    end
  end
end
