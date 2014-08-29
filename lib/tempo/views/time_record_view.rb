module Tempo
  module Views
    class << self

      # Container sends postpone: true through options
      def time_record_view(time_record, options={})
        ViewRecords::TimeRecord.new time_record, options
      end

      def start_time_record_view(time_record)
        ViewRecords::Message.new "time record started:"
        time_record_view time_record
      end

      def end_time_record_view(time_record)
        ViewRecords::Message.new "time record ended:"
        time_record_view time_record
      end

      def update_time_record_view(time_record)
        ViewRecords::Message.new "time record updated:"
        time_record_view time_record
      end

      def delete_time_record_view(time_record)
        ViewRecords::Message.new "time record deleted:"
        time_record_view time_record
      end
    end
  end
end
