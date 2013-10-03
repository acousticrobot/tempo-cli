module Tempo
  module Views
    class << self

      # single time record view, build according to options
      def time_record_view( record, options={} )
        view = []
        view << "time record started:" if options[:new_record]
        view << "time record ended:" if options[:close_record]
        view << "project: #{Tempo::Model::Project.find_by_id( record.project ).title}"
        view << "description: #{record.description}"
        view << "start time: #{record.start_time}"
        view << "end time: #{record.end_time}"
        return_view view, options
      end
    end
  end
end
