module Tempo
  module Views
    class << self

      def report_view options={}

        projects = options.fetch( :projects, Tempo::Model::Project.index )
        return no_items( "projects" ) if projects.empty?

        # TODO: index or days_index?
        time_records = options.fetch( :time_records, Tempo::Model::TimeRecord.days_index )
        return no_items( "time records" ) if time_records.empty?
        view = []

        time_records.each do |d_id, days_record|

          day = Tempo::Model::TimeRecord.day_id_to_time d_id
          view << "======================="
          view << day.strftime("Records for %m/%d/%Y:")
          view << ""

          days_record.each do |record|
            entry = time_record_listing record
            view << entry
          end

          view << ""

        end

        return_view view, options
      end
    end
  end
end