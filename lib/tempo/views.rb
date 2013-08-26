module Tempo
  module Views

    def self.return_view( view, output )
      if output
        view.each { |line| puts line }
      end
      view
    end

    def self.projects_list( project_array, current_project=nil, output=true )
      view = []
      project_array.each do |p|
        if p == current_project
          view << "* #{p}"
        else
          view << "  #{p}"
        end
      end
      return_view view, output
    end

    def self.options_report(global_options, options, args, output=true)
      view = []
      view << "global_options: #{global_options}"
      view << "options: #{options}"
      view << "args: #{args}"
      return_view view, output
    end
  end
end