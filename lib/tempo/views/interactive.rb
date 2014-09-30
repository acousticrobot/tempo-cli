module Tempo
  module Views
    class << self

      def interactive_query(message)
        ViewRecords::Message.new message, category: :interactive
      end

      def interactive_progress(message)
        ViewRecords::Message.new message, category: :interactive
      end

    end
  end
end
