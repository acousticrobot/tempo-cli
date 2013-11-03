# Tempo View Formatters are triggered by the View Reporter.
# The View Reporter sends it's stored view messages to each
# of it's formatters. It calls the method process records and
# passes in the view records.  If the formatter has a class method
# that handles the type of block passed in, it will process
# that view record. These class methods take the name "<record type>_block"
# where record type can be any child class of ViewRecord::Base
# see the screen formatter for an example of processing blocks.

module Tempo
  module Views
    module Formatters

      class Base

        # TODO: should options and global options be held within the formatter?
        def initialize options={}
          @options = options
        end

        # Here we check if our class methods include a proc block to handle the particular
        # record type.  See View Records for all possible record types.  See screen formatter
        # for examples of proc blocks.
        #
        def format_records records
          records.each do |record|
            class_block = "#{record.type}_block"
            send( class_block, record, @options ) if respond_to? class_block
          end
        end
      end
    end
  end
end
