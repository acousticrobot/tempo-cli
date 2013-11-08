module Tempo
  module Controllers
    class Arrange < Tempo::Controllers::Base
      @projects = Model::Project

      class << self

        def parse options, args

          return Views::arrange_parse_error unless args.include? ":"

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
            make_root_project options, child_args
          else
            make_child_project options, parent_args, child_args
          end
        end

        def make_root_project options, args
          root = match_project :arrange, options, args
          if root.parent == :root
            Views::arrange_already_root root
          else
            parent = match_project :arrange, {id: true}, root.parent
            parent.remove_child root
            @projects.save_to_file
            Views::arrange_root root
          end
        end

        def make_child_project options, parent_args, child_args
          parent = match_project :arrange, options, parent_args
          child = match_project :arrange, options, child_args
          parent << child
          @projects.save_to_file
          Views::arrange_parent_child parent, child
        end
      end #class << self
    end
  end
end
