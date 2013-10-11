module Tempo
  module Views
    class << self

      def return_message message, options={}
        view = ViewRecords::Message.new "a new message"
        formatter = Views::Formatters::Base.new
        formatter.add view
        formatter.print
      end

      # puts each line if output=true
      # else returns an array of view lines
      def return_view( view, options={} )
        output = options.fetch( :output, true )

        if output
          if view.is_a? String
            puts view
          else
            view.each { |line| puts line }
          end
        end
        view
      end

      # spacer for project titles, active project marked with *
      def active_indicator( project )
        indicator = project == Tempo::Model::Project.current ? "* " : "  "
      end

      def tag_view( tags, title_length=40 )
        # TODO: Manage the max title length
        spacer = [0, 40 - title_length].max
        view = " " * spacer
        return  view + "tags: none" if tags.length < 1

        view += "tags: [ "
        tags.each { |t| view += "#{t}, "}
        view[0..-3] + " ]"
      end

      def options_report( global_options, options, args )
        view = []
        view << "global_options: #{global_options}"
        view << "options: #{options}"
        view << "args: #{args}"
        return_view view, options
      end

      def added_item( item, request )
        return_message "added #{item}: #{request}", options
      end

      def deleted_item( item, request )
        return_message "deleted #{item}: #{request}", options
      end

      def switched_item( item, request )
        return_view "switched to #{item}: #{request}"
      end

      def no_items( items, err=false )
        raise "no #{items} exist" if err
        return_view "no #{items} exist"
      end

      def no_match( items, request, plural=true )
        match = plural ? "match" : "matches"
        raise "no #{items} #{match} the request: #{request}"
      end

      def already_exists( item, request )
        raise "#{item} '#{request}' already exists"
      end

      def checkout_assistance( options={} )
        view = []
        view << "checkout command run with no arguments"
        view << "perhaps you meant one of these?"
        view << "  tempo checkout --add <new project name>"
        view << "  tempo checkout <existing project>"
        view << "run `tempo checkout --help` for more information"
        return_view view
      end
    end
  end
end
