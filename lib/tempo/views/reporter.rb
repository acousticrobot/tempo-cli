# The Views Reporter is responsible for presenting all the views
# using the specified formatters. The Reporter is initialized in the GLI pre block,
# where all additional formats are added.
# The reporter executes the reports during the post block, displaying all views that
# have been added by the views.
#
# class instance variables:
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
      @@formats
      @@view_records

      class << self
        attr_accessor :view_records

        def add_format *formats
          @@formats ||= []
          formats.each {|format| @@formats << format}
        end

        def formats
          @@formats ||= []
        end

        # records can be added as an array of view_records,
        # or a single record.  They will be added to the end
        # of the current record array
        def add_view_record *records
          @@view_records ||= []
          records.each do |record|
            if /Views::ViewRecords/.match record.class.name
              @@view_records << record
            else
              raise InvalidViewRecordError
            end
          end
        end

        def view_records
          @@view_records ||= []
        end
      end
    end
  end
end