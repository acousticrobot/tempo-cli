module Tempo
  module Views
    class << self

      # puts each line if output=true
      # else returns an array of view lines
      def return_view( view, output )
        if output
          view.each { |line| puts line }
        end
        view
      end

      # spacer for project titles, active project marked with *
      def active_indicator( project )
        indicator = project == Tempo::Model::Project.current ? "* " : "  "
      end

      def tag_view( tags, title_length=40 )
        view = " " * (40 - title_length)
        return  view + "tags: none" if tags.length < 1

        view += "tags: [ "
        tags.each { |t| view += "#{t}, "}
        view[0..-3] + " ]"
      end


      # single project list, build according to options
      #
      def project_view( project, options={})

        if options[:verbose]
          options[:id] = true
          options[:tag] = true
        end
        options[:active] = options.fetch( :active, true )

        id = options[:id] ? "[#{project.id}] " : ""
        active = options[:active] ? active_indicator( project ) : ""
        depth = "  " * options[:depth] if options[:depth]
        title = project.title
        view = "#{id}#{active}#{depth}#{title}"
        tags = options[:tag] || options[:untag] ? tag_view( project.tags, view.length ) : ""
        view += tags
      end

      # list of projects, build according to options
      #
      def projects_list_view( options={} )

        projects = options.fetch( :projects, Tempo::Model::Project.index )
        return no_file( "projects" ) if projects.empty?

        output = options.fetch( :output, true )
        depth = options.fetch( :depth, 0 )
        parent = options.fetch( :parent, :root )

        view = Tempo::Model::Project.sort_by_title projects do |projects|
          view = []
          projects.each do |p|
            if p.parent == parent
              view << project_view( p, options )
              if not p.children.empty?
                child_opts = options.clone
                #child_opts[:projects] = projects
                child_opts[:depth] = depth + 1
                child_opts[:parent] = p.id
                child_opts[:output] = false
                child_array = projects_list_view child_opts
                view.push *child_array
              end
            end
          end
          view
        end

        return_view view, output
      end

      # list of projects, view build according to options
      def flat_projects_list_view( options={} )
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

      def options_report(global_options, options, args, output=true)
        view = []
        view << "global_options: #{global_options}"
        view << "options: #{options}"
        view << "args: #{args}"
        return_view view, output
      end

      def no_file( request )
        raise "no #{request} file exists"
      end

      def no_project( request )
        raise "no such project '#{request}'"
      end

      def ambiguous_project( matches, command, options={} )
        output = options.fetch( :output, true )
        puts "The following projects matched your search:"
        projects_list_view({ projects: matches })
        puts "please refine your search or use --exact to match args exactly"
        raise "cannot #{command} multiple projects"
      end
    end
  end
end
