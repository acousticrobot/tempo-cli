module Tempo
  module Views
    class << self

      def project_added project
        ViewRecords::Message.new "added project:"
        ViewRecords::Project.new project
      end

      def project_deleted project
        ViewRecords::Message.new "deleted project:"
        ViewRecords::Project.new project
      end

      def project_tags project
        ViewRecords::Message.new "altered project tags:"
        ViewRecords::Project.new project
      end

      def project_view project, depth=0
        ViewRecords::Project.new project, depth: depth
      end

      def projects_list_view projects=Tempo::Model::Project.index, parent=:root, depth=0
        return no_items( "projects" ) if projects.empty?

        Tempo::Model::Project.sort_by_title projects do |projects|
          projects.each do |p|

            if p.parent == parent
              ViewRecords::Project.new p, depth: depth

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
            ViewRecords::Project.new p
          end
        end
      end

      def ambiguous_project( matches, command )

        ViewRecords::Message.new "The following projects matched your search:"

        Tempo::Views::Reporter.add_options active: true
        projects_flat_list_view matches

        ViewRecords::Message.new "please refine your search or use --exact to match args exactly"

        ViewRecords::Message.new "cannot #{command} multiple projects", category: :error
      end

      def project_assistance
        view = []
        view << "you need to set up a new project before running your command"
        view << "run`tempo project --help` for more information"
        return_view view
        no_items :projects, true
      end
    end
  end
end
