module Tempo
  module Views
    class << self

      def time_record_listing record, options={}
        project_title = Model::Project.find_by_id( record.project ).title

        start_time = record.start_time.strftime('%H:%M')

        if record.end_time.kind_of? Time
          end_time = record.end_time
          running = " "
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

      def start_time_record_view record, options={}
        view = []
        view << "time record started:"
        view << time_record_listing( record, options={} )

        return_view view, options
      end

      def end_time_record_view record, options={}
        view = []
        view << "time record ended:"
        view << time_record_listing( record, options={} )

        return_view view, options
      end
    end
  end
end
