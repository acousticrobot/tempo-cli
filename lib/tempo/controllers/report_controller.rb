module Tempo
  module Controllers
    class Report < Tempo::Controllers::Base
      @projects = Model::Project
      @time_records = Model::TimeRecord

      class << self

        def report options, args

          if options[:from]
            options[:to] = options.fetch :to, "today"
            from = Chronic.parse options[:from]
            to = Chronic.parse options[:to]
            @time_records.load_days_records from, to

          elsif args.empty?
            @time_records.load_last_day

          else
            time = reassemble_the args

            begin
              day = Chronic.parse time
            rescue Exception => e
              binding.pry
              Tempo::Views.no_match "valid timeframe", time, false
            end
            @time_records.load_day_record day
          end

          Tempo::Views.no_items( "time records", err=true ) if @time_records.index.empty?

          Tempo::Views.report_view
        end
      end #class << self
    end
  end
end