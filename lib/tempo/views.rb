module Tempo
  module Views

    def self.return_view( view, output )
      if output
        view.each { |line| puts line }
      end
      view
    end

    def self.projects_list_view( options={} )

      projects = options.fetch( :projects, Tempo::Model::Project.index )
      output = options.fetch( :output, true )

      # replace 'current' with a find_by_id method
      current = nil
      titles = []
      projects.each do |p|
        titles << p.title
        current = p.title if Tempo::Model::Project.current == p
      end
      titles.sort!

      view = []
      titles.each do |t|
        if t == current
          view << "* #{t}"
        else
          view << "  #{t}"
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