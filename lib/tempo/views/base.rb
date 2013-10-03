module Tempo
  module Views
    class << self

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
        return_view "added #{item}: #{request}"
      end

      def deleted_item( item, request )
        return_view "deleted #{item}: #{request}"
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

      def ambiguous_project( matches, command, options={} )
        view = []
        view << "The following projects matched your search:"
        view.push *projects_list_view({ projects: matches, output: false })
        view << "please refine your search or use --exact to match args exactly"
        return_view view, options
        raise "cannot #{command} multiple projects"
      end

      def project_assistance
        view = []
        view << "you need to set up a new project before running your command"
        view << "run`tempo project --help` for more information"
        return_view view
        no_items :projects, true
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
