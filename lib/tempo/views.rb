module Tempo
  module Views
    class << self

      def return_view( view, output )
        if output
          view.each { |line| puts line }
        end
        view
      end

      def active_indicator( project )
        indicator = project == Tempo::Model::Project.current ? "* " : "  "
      end

      def projects_list_view( options={} )
        projects = options.fetch( :projects, Tempo::Model::Project.index )
        output = options.fetch( :output, true )

        view = Tempo::Model::Project.sort_by_title projects do |projects|
          view = []
          projects.each do |p|
            if options[:id]
              view << "[#{p.id}]\t#{active_indicator p}#{p.title}"
            else
              view << "#{active_indicator p}#{p.title}"
            end
          end
          view
        end

        return_view view, output
      end

      def tag_view( tags, options={} )
        output = options.fetch( :output, true )
        return return_view(["   tags: none"], output) if tags.length < 1
        view = "   tags: "
        tags.each { |t| view += "#{t}, "}
        return_view [view[0..-3]], output
      end

      def options_report(global_options, options, args, output=true)
        view = []
        view << "global_options: #{global_options}"
        view << "options: #{options}"
        view << "args: #{args}"
        return_view view, output
      end

      def no_project( request )
        raise "no such project '#{request}'"
      end

      def ambiguous_project( matches, command, options={} )
        output = options.fetch( :output, true )
        puts "The following projects matched your search:"
        projects_list_view({ projects: matches })
        puts "please refine your search"
        raise "cannot #{command} multiple projects"
      end
    end
  end
end
