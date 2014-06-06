module Tempo
  module Controllers
    class Checkout < Tempo::Controllers::Base
      @projects = Model::Project

      class << self

        def add_project options, args
          request = reassemble_the args, options[:add]

          if @projects.include? request
            Views::already_exists_error "project", request

          else
            project = @projects.new({ title: request, current: true })
            @projects.save_to_file options
            Views::project_checkout project
          end
        end

        def existing_project options, args

          match = match_project :checkout, options, args

          if match
            if @projects.current == match
              Views::project_already_current match
            else
              @projects.current = match
              @projects.save_to_file options
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
