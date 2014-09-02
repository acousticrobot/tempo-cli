module Tempo
  module Views
    class << self

      # called in the pre block, pushes relavent options to the reporter
      def initialize_view_options(command, global_options, options)
        view_opts = {}
        view_opts[:verbose] = global_options[:verbose]
        view_opts[:id] = global_options[:id]
        case command
        when :project, :p
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
            view_opts[:id] = global_options[:id] || options[:id] ? true : false
          end
        end
        Tempo::Views::Reporter.add_options view_opts
      end

      # called in the preblock when verbose = true
      def options_report(command, global_options, options, args)
        globals_list = "global options: "
        global_options.each {|k,v| globals_list += "#{k} = #{v}, " if k.kind_of? String and k.length > 1 and !v.nil? }
        ViewRecords::Message.new globals_list[0..-2], category: :debug

        options_list = "command options: "
        options.each {|k,v| options_list += "#{k} = #{v}, " if k.kind_of? String and k.length > 1  and !v.nil? }
        ViewRecords::Message.new options_list[0..-2], category: :debug


        ViewRecords::Message.new "command: #{command}", category: :debug
        ViewRecords::Message.new "args: #{args}", category: :debug
      end

      def no_items(items, category=:info)
        ViewRecords::Message.new "no #{items} exist", category: category
        if items == "projects"
          ViewRecords::Message.new "You must at least one project before you can begin tracking time"
          ViewRecords::Message.new "run `tempo project --help` for more information"
        end
      end

      def message(message)
        ViewRecords::Message.new message, category: :info
      end

      def warning(message)
        ViewRecords::Message.new message, category: :warning
      end

      def error(message)
        ViewRecords::Message.new message, category: :error
      end

      def no_match_error(items, request, plural=true)
        match = plural ? "match" : "matches"
        ViewRecords::Message.new "no #{items} #{match} the request: #{request}", category: :error
      end

      def already_exists_error(item, request)
        ViewRecords::Message.new "#{item} '#{request}' already exists", category: :error
      end

      def checkout_assistance(options={})
        ViewRecords::Message.new "checkout command run with no arguments"
        ViewRecords::Message.new "perhaps you meant one of these?"
        ViewRecords::Message.new "  tempo checkout --add <new project name>"
        ViewRecords::Message.new "  tempo checkout <existing project>"
        ViewRecords::Message.new "run `tempo checkout --help` for more information"
      end
    end
  end
end
