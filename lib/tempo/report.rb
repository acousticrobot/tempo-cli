module Tempo
  module Report

    def self.list_projects( project_array, current_project )
      project_array.each do |p|
        if p == current_project
          puts "* #{p}"
        else
          puts "  #{p}"
        end
      end
    end

    def self.options_report(global_options, options, args)
      puts "global_options: #{global_options}"
      puts "options: #{options}"
      puts "args: #{args}"
    end
  end
end