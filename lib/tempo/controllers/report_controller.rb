module Tempo
  module Controllers
    class Report < Tempo::Controllers::Base
      @projects = Model::Project
      @time_records = Model::TimeRecord

      class << self

        def report options, args
          @time_records.load_last_day
          Tempo::Views.no_items( "time records", err=true ) if @time_records.index.empty?

          Tempo::Views.report_view
        end
      end #class << self
    end
  end
end