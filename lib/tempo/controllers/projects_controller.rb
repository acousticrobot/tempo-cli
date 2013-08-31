module Tempo
  module Controllers
    class ProjectsController

      class << self

        def load
          if File.exists?( File.join( ENV['HOME'], '.tempo', Tempo::Model::Project.file ))
            Tempo::Model::Project.read_from_file
            Tempo::Model::Project
          end
        end

        def index( args )
          request = Tempo::reassemble_the args

          if args.empty?
            Tempo::Views::projects_list_view

          else
            matches = Tempo::fuzzy_match Tempo::Model::Project, args, "title"

            if matches.empty?
              puts "no projects match '#{request}'"

            else
              Tempo::Views::projects_list_view({ projects: matches })
            end
          end
        end

        def add( args )
          request = Tempo::reassemble_the args

          if Tempo::Model::Project.list.include? request
            raise "project '#{request}' already exists"
          else
            Tempo::Model::Project.new({ title: request })
            Tempo::Model::Project.save_to_file
            puts "added project '#{request}'"
          end
        end

        def delete( options, args )

          # first arg without quotes from GLI will be the value of delete
          request = Tempo::reassemble_the args, options[:delete]
          matches = Tempo::fuzzy_match Tempo::Model::Project, args, "title"

          if matches.length == 0
            raise "no such project '#{request}'"

          elsif matches.length > 1
            puts "The following projects matched your search:"
            Tempo::Views::projects_list_view matches
            puts "Please refine your search"

          else
            match = matches[0]
            if match == Tempo::Model::Project.current
              raise "cannot delete the active project"
            end

            if Tempo::Model::Project.index.include?(match)
              match.delete
              Tempo::Model::Project.save_to_file
              if !options[:list]
                puts "deleted project '#{match.title}'"
              else
                Tempo::Views::projects_list_view
              end
            end
          end
        end
      end
    end
  end
end