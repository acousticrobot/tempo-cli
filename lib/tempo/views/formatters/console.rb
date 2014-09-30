# The Console block handles interactive queries and progress reports.
# It is required when reporting must be done in 'real time' rather than compiled
# during runtime and then presented at the end (see Views::Screen). It is the only
# formatter that receives blocks as soon as they are handed to the Reporter

module Tempo
  module Views
    module Formatters

      class Console < Tempo::Views::Formatters::Base


        def message_block(record)
          record.format do |m|
            case m.category
            when :immediate
              puts "#{m.message}"
            when :progress
              puts "#{m.message}..."
            end
            m.message
          end
        end

        def query_block(query)
          query.format do |q|
            puts q.query
            response = Readline.readline('> ', true)
          end
        end

      end
    end
  end
end
