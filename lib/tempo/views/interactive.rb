module Tempo
  module Views
    class << self

      # Must be allowed to return results
      def interactive_query(query)
        ViewRecords::Query.new query
      end

      def interactive_progress(message)
        ViewRecords::Message.new message, category: :progress
      end

      def interactive_progress_partial(message)
        ViewRecords::Message.new message, category: :progress_partial
      end

      def interactive_confirm_clean
        query = "\nCleaning Tempo records resaves all records, looking for errors.\n" +
                  "In the event that a record cannot be corrected, you wil be prompted to repair the record manually.\n" +
                  "A backup of the records will also be created before any changes are made.\n\n" +
                  "Do you wish to continue? [YyNn]"
        interactive_query(query)
      end

      def interactive_confirm_move_old_records
        query = "\nYou have files which match an older file structure, do you want to move them so they will be included in your records? [YyNn]"
        interactive_query(query)
      end
    end
  end
end
