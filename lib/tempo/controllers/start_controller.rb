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
            time_in = Time.new()
          else
            time_in = Time.parse options[:at]
          end

          return Views.no_match_error( "valid timeframe", options[:at], false ) if time_in.nil?

          opts = { start_time: time_in }
          opts[:description] = reassemble_the args

          if options[:end]
            time_out = Time.parse options[:end]
            return Views.no_match_error( "valid timeframe", options[:end], false ) if time_out.nil?
            opts[:end_time] = time_out
          end

          @time_records.load_last_day options

          if options[:resume]
            last_record = @time_records.last_record

            return Views.error("cannot resume last time record when it is still running") if last_record.running?

            opts[:description] = last_record.description

            # we use the last used project, but don't save it as current
            # in case a different project has been checked out.
            @projects.current = @projects.find_by_id(last_record.project)

            record = @time_records.new(opts)

          else
            record = @time_records.new(opts)
          end

          @time_records.save_to_file options

          Views.start_time_record_view record

        end

      end #class << self
    end
  end
end
