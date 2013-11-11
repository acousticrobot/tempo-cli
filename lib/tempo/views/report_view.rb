module Tempo
  module Views
    class << self

      def report_records_view options={}

        projects = options.fetch( :projects, Tempo::Model::Project.index )
        return no_items( "projects" ) if projects.empty?

        time_records = options.fetch( :time_records, Tempo::Model::TimeRecord.days_index )
        return no_items( "time records" ) if time_records.empty?

        time_records.each do |d_id, days_record|

          day = Tempo::Model::TimeRecord.day_id_to_time d_id
          ViewRecords::Message.new ""
          ViewRecords::Message.new day.strftime("Records for %m/%d/%Y:")

          days_record.each do |time_record|
            time_record_view time_record
          end
        end
      end
    end
  end
end