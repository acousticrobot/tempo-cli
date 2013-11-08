module Tempo
  module Views
    class << self

      # called in the pre block, pushes relavent options to the reporter
      def initialize_view_options command, global_options, options
        view_opts = {}
        view_opts[:verbose] = global_options[:verbose]
        case command
        when :project
          if global_options[:verbose]
            view_opts[:id] = true
            view_opts[:tags] = true
            view_opts[:active] = true
            view_opts[:depth] = true
          else
            if options[:list]
              view_opts[:depth] = true
              view_opts[:active] = true
            end
            view_opts[:tags] = options[:tag] || options[:untag] ? true : false
            view_opts[:id] = options[:id] ? true : false
          end
        end
        Tempo::Views::Reporter.add_options view_opts
      end

      # DEPRACATE- View is returned in post
      #
      # puts each line if output=true
      # else returns an array of view lines
      def return_view( view, options={} )
        output = options.fetch( :output, true )

        if output
          if view.is_a? String
            puts view
          else
            view.each { |line| puts line }
          end
        end
        view
      end

      # # spacer for project titles, active project marked with *
      # def active_indicator( project )
      #   indicator = project == Tempo::Model::Project.current ? "* " : "  "
      # end

      # def tag_view( tags, title_length=40 )
      #   # TODO: Manage the max title length
      #   spacer = [0, 40 - title_length].max
      #   view = " " * spacer
      #   return  view + "tags: none" if tags.length < 1

      #   view += "tags: [ "
      #   tags.each { |t| view += "#{t}, "}
      #   view[0..-3] + " ]"
      # end

      def options_report( command, global_options, options, args )
        globals_list = "global options: "
        global_options.each {|k,v| globals_list += "#{k} = #{v}, " if k.kind_of? String and k.length > 1 and !v.nil? }
        ViewRecords::Message.new globals_list[0..-2], category: :debug

        options_list = "command options: "
        options.each {|k,v| options_list += "#{k} = #{v}, " if k.kind_of? String and k.length > 1  and !v.nil? }
        ViewRecords::Message.new options_list[0..-2], category: :debug


        ViewRecords::Message.new "command: #{command}", category: :debug
        ViewRecords::Message.new "args: #{args}", category: :debug
      end

      def no_items( items, category=:info )
        ViewRecords::Message.new "no #{items} exist", category: category
      end

      def no_match( items, request, plural=true )
        match = plural ? "match" : "matches"
        ViewRecords::Message.new "no #{items} #{match} the request: #{request}", category: :error
      end

      def already_exists( item, request )
        raise "#{item} '#{request}' already exists"
      end

      def checkout_assistance( options={} )
        view = []
        view << "checkout command run with no arguments"
        view << "perhaps you meant one of these?"
        view << "  tempo checkout --add <new project name>"
        view << "  tempo checkout <existing project>"
        view << "run `tempo checkout --help` for more information"
        return_view view
      end
    end
  end
end
