module Tempo
  module Controllers
    class Projects < Tempo::Controllers::Base
      @projects = Model::Project

      class << self

        def load
          if File.exists?( File.join( ENV['HOME'], '.tempo', @projects.file ))
            @projects.read_from_file
          end
        end

        def index( args )
          request = reassemble_the args

          if args.empty?
            Views::projects_list_view

          else
            matches = fuzzy_match @projects, args, "title"

            if matches.empty?
              puts "no projects match '#{request}'"

            else
              Views::projects_list_view({ projects: matches })
            end
          end
        end

        def add( args )
          request = reassemble_the args

          if @projects.list.include? request
            raise "project '#{request}' already exists"
          else
            @projects.new({ title: request })
            @projects.save_to_file
            puts "added project '#{request}'"
          end
        end

        def delete( options, args )

          # first arg without quotes from GLI will be the value of delete
          request = reassemble_the args, options[:delete]
          matches = fuzzy_match @projects, args, "title"

          if matches.length == 0
            raise "no such project '#{request}'"

          elsif matches.length > 1
            puts "The following projects matched your search:"
            Views::projects_list_view matches
            puts "Please refine your search"

          else
            match = matches[0]
            if match == @projects.current
              raise "cannot delete the active project"
            end

            if @projects.index.include?(match)
              match.delete
              @projects.save_to_file
              if !options[:list]
                puts "deleted project '#{match.title}'"
              else
                Views::projects_list_view
              end
            end
          end
        end
      end #class << self
    end
  end
end