# Wrapper object for ViewRecords, able to collect multiple viewrecords
# this allows for a begining and end record, collecting total duration, etc.

# @pre = Optional record which is sent to the formatter before the collection
# @post = Optionsal record which is sent to the formatter after the collection
module Tempo
  module Views
    module ViewRecords

      class Container
        attr_accessor :type, :pre, :post

        def initialize(options={})
          # TODO: add error checking for pre and post, better handling nil values
          @pre = options.fetch( :pre, nil )
          @post = options.fetch( :post, nil )
          @type = "container"
          @collection = [] # handle records on init?
          Reporter.add_view_record self unless options[:postpone]
        end

        # add a splat?
        def add(record)
          @collection << record
        end

        #TODO: Implement pre and post method with logic to handle both
        #      views reocrds and strings. See post in TimeRecordContainer
        #      for use case

        def records
          @collection
        end
      end
    end
  end
end


module Tempo
  module Views
    module ViewRecords

      # Handle a collection of time records
      # Pre can hold the title of the collection (date, project, etc.)
      # postreturns the total duration of all contained records
      class TimeRecordContainer < ViewRecords::Container
        attr_accessor :duration

        def initialize(options={})
          super options
          @type = "time_record_container"
          @duration = Duration.new
        end

        def add(record)
          # TODO: fail if not a time record
          super record
          @duration.add record.duration.total
        end

        def post
          ViewRecords::Message.new "Total: ------- [#{duration.format}] --------------------------------\n\n", postpone: true
        end
      end
    end
  end
end
