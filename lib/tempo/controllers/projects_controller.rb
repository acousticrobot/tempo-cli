module Tempo
  module Controllers
    class Projects < Tempo::Controllers::Base
      @projects = Model::Project

      class << self

        def load
          if File.exists?( File.join( ENV['HOME'], 'tempo', @projects.file ))
            @projects.read_from_file
          end
        end

        def index options, args

          request = reassemble_the args

          if args.empty?
            Views::projects_list_view

          else
            matches = filter_projects_by_title options, args

            if matches.empty?
              Views::no_match_error "projects", request

            else
              Views::projects_list_view matches
            end
          end
        end

        def show_active
          if @projects.index.empty?
            Views::no_items "projects"
          else
            Views::Reporter.add_options active: true
            Views::project_view @projects.current
          end
        end

        def add options, args, tags=nil
          request = reassemble_the args

          if @projects.include? request
            Views::already_exists_error "project", request

          else
            project = @projects.new({ title: request, tags: tags })

            if @projects.index.length == 1
              @projects.current = project
            end

            @projects.save_to_file

            Views::project_added project
          end
        end

        def delete options, args

          reassemble_the args, options[:delete]
          match = match_project :delete, options, args

          if match
            if match == @projects.current
              return Views::ViewRecords::Message.new "cannot delete the active project", category: :error
            end

            if @projects.index.include?(match)
              match.delete
              @projects.save_to_file
              Views::projects_list_view if options[:list]
              Views::project_deleted match
            end
          end
        end

        # add a project with tags, or tag or untag an existing project
        def tag options, args

          # TODO @projects_find_by_tag if args.empty?

          tags = options[:tag].split if options[:tag]
          untags = options[:untag].split if options[:untag]

          # add a new project
          if options[:add]
            add options, args, tags

          else
            command = options[:tag] ? "tag" : "untag"
            match = match_project command, options, args

            if match
              match.tag tags
              match.untag untags
              @projects.save_to_file
              Views::project_tags match
            end
          end
        end
      end #class << self
    end
  end
end
