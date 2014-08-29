# Tempo View Formatters are triggered by the View Reporter.
# The View Reporter sends it's stored view messages to each
# of it's formatters. It calls the method format_records and
# passes in the view records.  If the formatter has a class method
# that handles the type of block passed in, it will process
# that view record. These class methods take the name "<record type>_block"
# where record type can be any child class of ViewRecord::Base
# see the screen formatter for an example of processing blocks.

module Tempo
  module Views
    module Formatters

      class Base

        def initialize(options={})
          @options = options
        end

        def report(record)
          class_block = "#{record.type}_block"

          # We handle containers separately
          if /container/.match class_block
            format_records_container(record)
          else
            send(class_block, record) if respond_to? class_block
          end
        end

        # Here we check if our class methods include a proc block to handle the particular
        # record type.  See View Records for all possible record types.  See screen formatter
        # for examples of proc blocks.
        #
        def format_records(records)
          records.each do |record|
            report record
          end
        end

        # Records containers handle nested records
        def format_records_container(container)
          report container.pre if container.pre
          container.records.each do |record|
            report record
          end
          report container.post if container.post
        end
      end
    end
  end
end
