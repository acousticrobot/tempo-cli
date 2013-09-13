module Tempo
  module Controllers
    class Arrange < Tempo::Controllers::Base
      @projects = Model::Project

      class << self

        def parse( options, args )

          raise "arrange requires a colon (:) in the arguments" unless args.include? ":"

          parent_args = []
          child_args = []
          in_parent = true
          args.each do |a|
            if a != ":"
              in_parent ? parent_args << a : child_args << a
            else
              in_parent = false
            end
          end

          if parent_args.empty?
            make_root_project( options, child_args )
          else
            make_child_project( options, parent_args, child_args )
          end
        end

        def match_project( options, args )
          if options[:id]
            match = @projects.find_by_id args[0]
            Views::no_items "projects", args if not match
          else
            matches = filter_projects_by_title options, args
            request = reassemble_the args
            match = single_match( matches, request, :arrange )
          end

          match
        end

        def make_root_project( options, args)
          root = match_project( options, args)
          if root.parent == :root
            puts "#{root.title} is already a root project"
          else
            parent = match_project( {id: true}, root.parent )
            parent.delete_child root
            @projects.save_to_file
          end
          puts "root project: #{root.title}"
        end

        def make_child_project( options, parent_args, child_args )
          parent = match_project( options, parent_args)
          child = match_project( options, child_args)
          parent << child
          @projects.save_to_file
          puts "parent project: #{parent.title}"
          puts "child project: #{child.title}"
        end

      end #class << self
    end
  end
end
