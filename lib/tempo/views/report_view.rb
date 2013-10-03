module Tempo
  module Views
    class << self

      def report_record_view record, options={}
          project_title = Model::Project.find_by_id( record.project ).title

          start_time = record.start_time.strftime('%H:%M')

          if record.end_time.kind_of? Time
            end_time = record.end_time
            running = ""
          else
            end_time = Time.now()
            running = "*"
          end

          seconds = end_time - record.start_time
          hours = ( seconds / 3600 ).to_i
          minutes = ( seconds / 60 - hours * 60 ).to_i.to_s.rjust(2, '0')
          duration = "#{ hours }:#{ minutes }"
          end_time = end_time.strftime('%H:%M')

          description = record.description ? ": #{record.description}" : ""

          "#{start_time} - #{end_time}#{running} [#{duration}] #{project_title}#{description}"
      end

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
            entry = report_record_view record
            view << entry
          end

          view << ""

        end

        return_view view, options
      end
    end
  end
end