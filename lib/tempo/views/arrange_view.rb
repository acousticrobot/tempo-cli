module Tempo
  module Views
    class << self

      def arrange_parent_child parent, child
        ViewRecords::Message.new "parent project:"
        ViewRecords::Project.new parent
        ViewRecords::Message.new "child project:"
        ViewRecords::Project.new child
      end

      def arrange_root project
        ViewRecords::Message.new "root project:"
        ViewRecords::Project.new project
      end

      def arrange_already_root project
        ViewRecords::Message.new "already a root project:"
        ViewRecords::Project.new project
      end

      def arrange_parse_error
        ViewRecords::Message.new "arrange requires a colon (:) in the arguments", category: :error
      end
    end
  end
end