# Wrapper object for ViewRecords, able to collect multiple viewrecords
# this allows for a begining and end record, collecting total duration, etc.
# TODO: Build a generic container object, implement specifics for the TimeRecordsContainer
# and then move the generic container into the base.rb file

# @pre = Optional record which is sent to the formatter before the collection
# @post = Optionsal record which is sent to the formatter after the collection
module Tempo
  module Views
    module ViewRecords

      class Container
        attr_accessor :type, :pre, :post, :collection

        def initialize(options={})
          # TODO: add error checking for pre and post, better handling nil values
          @pre = options.fetch( :pre, nil )
          @post = options.fetch( :post, nil )
          @type = "container"
          @collection = [] # handle records on init?
          Reporter.add_view_record self
        end

        # add a splat?
        def add(record)
          @collection << record
        end

        # change collection to records, keep it simple?
        def records
          @collection
        end

        def format(&block)
          block ||= lambda {|m| "#{m.message}"}
          block.call self
        end
      end
    end
  end
end


module Tempo
  module Views
    module ViewRecords
      class TimeRecordContainer < ViewRecords::Container

      end
    end
  end
end
