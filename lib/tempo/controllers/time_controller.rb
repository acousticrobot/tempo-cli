module Tempo
  module Controllers
    class Time < Tempo::Controllers::Base
      @projects = Model::Project

      class << self

        def add_project( options, args )
          request = reassemble_the args, options[:add]

          puts "attempting to add #{request}"

          # TODO projects.include? :title, request
          if @projects.list.include? request
            raise "project '#{request}' already exists"

          else
            project = @projects.new({ title: request, current: true })
            @projects.save_to_file
            puts "switched to new project '#{project.title}'"
          end
        end

      end #class << self
    end
  end
end