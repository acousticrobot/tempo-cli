# The Views Reporter is responsible for presenting all the views
# using the specified formatters. The Reporter is initialized in the GLI pre block,
# where all additional formats are added.
# The reporter executes the reports during the post block, displaying all views that
# have been added by the views.
#
# class instance variables:
#
# @@console
#   A shell formtter which receives view records as they are created and can
#   intercept messages that should be displayed in real time, as well as interactive
#   prompts
#
# @@formats
#   an array of formatters, which will be passed the view records on exit
#   Reporter will always run the error formater first, to check for errors in
#   the view reports, followed by all added formatters, and then finally the screen
#   formatter.  This allows additional formatters to add view records, which
#   will be presented on screen.
#
# @@view_records
#   add view_records

module Tempo
  module Views

    class Reporter
      @@console
      @@formats
      @@view_records
      @@options

      class << self
        attr_accessor :view_records

        def add_format(*formats)
          @@formats ||= []
          formats.each {|format| @@formats << format}
        end

        def formats
          @@formats ||= []
        end

        def options
          @@options ||= {}
        end

        # All records are sent directly to the console, so it can decide if
        # action is required immediately based on the type of record
        def console
          @@console ||= Formatters::Console.new(options)
        end

        def add_options(options)
          @@options ||= {}
          @@options.merge! options
        end

        def add_view_record(record)
          @@view_records ||= []

          if /Views::ViewRecords/.match record.class.name
            @@view_records << record

            # console must be able to return a value
            return console.report record
          else
            raise InvalidViewRecordError
          end
        end

        def view_records
          @@view_records ||= []
        end

        def report
          # TODO send records to added formatters
          screen_formatter = Formatters::Screen.new(options)
          screen_formatter.format_records view_records
        end
      end
    end
  end
end
