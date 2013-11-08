module Tempo
  module Views
    class << self

      def project_view project, depth=0
        ViewRecords::Project.new project, depth: depth
      end

      def projects_list_view projects=Tempo::Model::Project.index, parent=:root, depth=0
        return no_items( "projects" ) if projects.empty?

        Tempo::Model::Project.sort_by_title projects do |projects|
          projects.each do |p|

            if p.parent == parent
              project_view p, depth

              if not p.children.empty?
                next_depth = depth + 1
                next_parent = p.id
                child_array = projects_list_view projects, next_parent, next_depth
              end
            end
          end
        end
      end

      # list of sorted projects, no hierarchy
      def projects_flat_list_view projects=Tempo::Model::Project.index

        Tempo::Model::Project.sort_by_title projects do |projects|
          projects.each do |p|
            project_view p
          end
        end
      end

      def project_added project
        ViewRecords::Message.new "added project:"
        project_view project
      end

      def project_deleted project
        ViewRecords::Message.new "deleted project:"
        project_view project
      end

      def project_checkout project
        ViewRecords::Message.new "switched to project:"
        project_view project
      end

      def project_already_current project
        ViewRecords::Message.new "already on project:"
        project_view project
      end

      def project_tags project
        ViewRecords::Message.new "altered project tags:"
        project_view project
      end

      def ambiguous_project( matches, command )

        ViewRecords::Message.new "The following projects matched your search:"

        Tempo::Views::Reporter.add_options active: true
        projects_flat_list_view matches

        ViewRecords::Message.new "please refine your search or use --exact to match args exactly"

        ViewRecords::Message.new "cannot #{command} multiple projects", category: :error
      end

      def project_assistance
        ViewRecords::Message.new "you need to set up a new project before running your command"
        ViewRecords::Message.new "run`tempo project --help` for more information"
        no_items "projects", :error
      end
    end
  end
end
