module Tempo
  module Controllers
    class Checkout < Tempo::Controllers::Base
      @projects = Model::Project

      class << self

        def add_project( options, args )
          request = reassemble_the args, options[:add]

          puts "attempting to add #{request}"

          # TODO projects.include? :title, request
          if @projects.list.include? request
            raise "project '#{request}' already exists"

          else
            project = @projects.new({ title: request, current: true })
            @projects.save_to_file
            puts "switched to new project '#{project.title}'"
          end
        end

        def existing_project( args )

          #TODO: create project.find_by
          matches = fuzzy_match @projects, args, "title"

          if matches.empty?
            puts "no projects match '#{reassemble_the args}'"

          elsif matches.length > 1
            puts "multiple projects found:"
            # TODO projects_refine
            Views::projects_list_view({ projects: matches })

          else
            project = matches[0]
            # TODO project.current?
            if @projects.current == project
              puts "already on project '#{project.title}'"
            else
              @projects.current project
              puts "switched to project '#{project.title}'"
            end
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