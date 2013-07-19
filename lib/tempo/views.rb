module Tempo
  module Views

    def self.projects_list( project_array, current_project=nil )
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