module Tempo
  module Views
    module Formatters

      class Base
        attr_reader :view

        class << self

          def message_block record, options={}
            record.format do |m|
              # TODO: raise this now, or pass multiple records through first?
              raise m.message if m.category == :error
              "#{m.message}"
            end
          end
        end

        def initialize options={}
          @options = options.clone
          @records = options.fetch( :records, [] )
          @view = []
        end

        def print
          @view.each {|view| puts view }
        end

        def add records
          if records.kind_of? Array
            @records.push *records

          elsif /Views::ViewRecords/.match records.class.name
            @records << records
          end
          process_view
        end

        def process_view
          @view = []
          @records.each do |record|
            class_block = "#{record.type}_block"
            if self.class.respond_to? class_block
              line = self.class.send( class_block, record, @options )
            else
              line = record.format
            end
            @view << line
          end
        end
      end
    end
  end
end