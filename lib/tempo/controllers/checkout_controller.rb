module Tempo
  module Controllers
    class Checkout < Tempo::Controllers::Base
      @projects = Model::Project

      class << self

        def add_project options, args
          request = reassemble_the args, options[:add]

          if @projects.include? request
            Views::already_exists "project", request

          else
            project = @projects.new({ title: request, current: true })
            @projects.save_to_file
            Views::project_checkout project
          end
        end

        def existing_project options, args

          if options[:id]
            match = @projects.find_by_id args[0]
            Views::no_items "projects", options[:id] if not match

          else
            matches = filter_projects_by_title options, args

            request = reassemble_the args
            match = single_match matches, request, :checkout
          end

          if match
            if @projects.current == match
              Views::project_already_current match
            else
              @projects.current = match
              @projects.save_to_file
              Views::project_checkout match
            end
          end
        end

        def assistance
          Views::checkout_assistance
        end
      end #class << self
    end
  end
end
