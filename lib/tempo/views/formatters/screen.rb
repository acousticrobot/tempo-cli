# Tempo View Formatters are triggered by the View Reporter.
# The View Reporter sends it's stored view messages to each
# of it's formatters. It calls the method process records and
# passes in the view records.  If the formatter has a class method
# that handles the type of block passed in, it will process
# that view record. These class methods take the name "<record type>_block"
# where record type can be any child class of ViewRecord::Base
# see <TODO> for an example of proc blocks.

module Tempo
  module Views
    module Formatters

      class Screen < Tempo::Views::Formatters::Base

        def message_block record, options={}
          record.format do |m|
            case m.category
            when :error
              raise m.message
            when :info
              puts m.message
            end
            m.message
          end

        end
      end
    end
  end
end