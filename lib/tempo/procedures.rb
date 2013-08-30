module Tempo
  module Procedures

    def self.load_projects
      if File.exists?( File.join( ENV['HOME'], '.tempo', Tempo::Project.file ))
        Tempo::Project.read_from_file
        Tempo::Project
      end
    end

    def self.list_projects( args )
      request = Tempo::reassemble_the args

      if args.empty?
        Tempo::Views::projects_list_view

      else
        matches = Tempo::fuzzy_match Tempo::Project, args, "title"

        if matches.empty?
          puts "no projects match '#{request}'"

        else
          Tempo::Views::projects_list_view({ projects: matches })
        end
      end
    end

    def self.add_project( args )
      request = Tempo::reassemble_the args

      if Tempo::Project.list.include? request
        raise "project '#{request}' already exists"
      else
        Tempo::Project.new({ title: request })
        Tempo::Project.save_to_file
        puts "added project '#{request}'"
      end
    end

    def self.delete_project( options, args )

      # first arg without quotes from GLI will be the value of delete
      request = Tempo::reassemble_the args, options[:delete]
      matches = Tempo::fuzzy_match Tempo::Project.list, args

      if matches.length == 0
        raise "no such project '#{request}'"

      elsif matches.length > 1
        puts "The following projects matched your search:"
        matches.each do |m|
          puts "  #{m}"
        end
        puts "Please refine your search"

      else
        project = matches[0]
        if project == Tempo::Project.find( "id", Tempo::Project.current ).title
          raise "cannot delete the active project"
        end

        if Tempo::Project.list.include?(project)
          Tempo::Project.find( "title", project ).delete
          Tempo::Project.save_to_file
          if !options[:list]
            puts "deleted project '#{project}'"
          else
            Tempo::Views::projects_list_view
          end
        end
      end
    end

  end
end