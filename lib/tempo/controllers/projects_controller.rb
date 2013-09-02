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

        def add( args, tags=nil )
          request = reassemble_the args

          if @projects.list.include? request
            raise "project '#{request}' already exists"
          else
            @projects.new({ title: request, tags: tags })
            @projects.save_to_file
            puts "added project '#{request}'"
          end
        end

        def delete( options, args )

          # first arg without quotes from GLI will be the value of delete
          request = reassemble_the args, options[:delete]
          matches = fuzzy_match @projects, args, "title"

          if matches.length == 0
            Views::no_project request

          elsif matches.length > 1
            Views::ambiguous_project matches, "delete"

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

        def tag( options, args )
          request = reassemble_the args
          tags = options[:tag].split if options[:tag]
          untags = options[:untag].split if options[:untag]

          if options[:add]
            add args, tags
            Views::tag_view tags

          else
            matches = fuzzy_match @projects, args, "title"

            if matches.length == 0
              Views::no_project request

            elsif matches.length > 1
              command = options[:tag] ? "tag" : "untag"
              Views::ambiguous_project matches, command

            else
              match = matches[0]
              match.tag tags
              match.untag untags
              @projects.save_to_file
              puts "project: #{match.title}"
              Views::tag_view match.tags
            end
          end
        end
      end #class << self
    end
  end
end