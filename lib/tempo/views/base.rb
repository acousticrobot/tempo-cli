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

      def no_match_error( items, request, plural=true )
        match = plural ? "match" : "matches"
        ViewRecords::Message.new "no #{items} #{match} the request: #{request}", category: :error
      end

      def already_exists_error( item, request )
        ViewRecords::Message.new "#{item} '#{request}' already exists", category: :error
      end

      def checkout_assistance( options={} )
        ViewRecords::Message.new "checkout command run with no arguments"
        ViewRecords::Message.new "perhaps you meant one of these?"
        ViewRecords::Message.new "  tempo checkout --add <new project name>"
        ViewRecords::Message.new "  tempo checkout <existing project>"
        ViewRecords::Message.new "run `tempo checkout --help` for more information"
      end
    end
  end
end
