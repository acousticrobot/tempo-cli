module Tempo
  module Controllers
    class Checkout < Tempo::Controllers::Base
      @projects = Model::Project

      class << self

        def add_project( options, args )
          request = reassemble_the args, options[:add]

          puts "attempting to add #{request}"

          if @projects.include? request
            Views::already_exists "project", request

          else
            project = @projects.new({ title: request, current: true })
            @projects.save_to_file
            Views::switched_item "new project", project.title
          end
        end

        def existing_project( options, args )

          if options[:id]
            match = @projects.find_by_id args[0]
            Views::no_items "projects", options[:id] if not match

          else
            matches = filter_projects_by_title options, args

            request = reassemble_the args
            match = single_match matches, request, :checkout
          end

          # TODO project.current?
          if @projects.current == match
            puts "already on project: #{match.title}"
          else
            @projects.current match
            @projects.save_to_file
            Views::switched_item "project", match.title
          end
        end

        def assistance
          puts "checkout command run with no arguments"
          puts "perhaps you meant one of these?"
          puts "  tempo checkout --add <new project name>"
          puts "  tempo checkout <existing project>"
          puts "run `tempo checkout --help` for more information"
        end

      end #class << self
    end
  end
end