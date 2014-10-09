# The Console block handles interactive queries and progress reports.
# It is required when reporting must be done in 'real time' rather than compiled
# during runtime and then presented at the end (see Views::Screen). It is the only
# formatter that receives blocks as soon as they are handed to the Reporter

module Tempo
  module Views
    module Formatters

      class Interactive < Tempo::Views::Formatters::Base


        def message_block(record)
          record.format do |m|
            case m.category
            when :immediate
              puts "#{m.message}"
            when :progress
              puts "#{m.message}..."
            when :progress_partial
              $stdout.sync = true
              print "#{m.message}..."
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

        def format_records_container(container)
          # Pass through over-ride
          # We don't allow interactive containers at this time because they
          # would need to be able to detect when the container is complete.
          # (report containers raised errors on nil durations).
        end
      end
    end
  end
end
