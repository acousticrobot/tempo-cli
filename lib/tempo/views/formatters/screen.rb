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

        def message_block record
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

        def duration_block record
          record.format do |d|
            puts "#{ d.hours.to_s }:#{ d.minutes.to_s.rjust(2, '0') }"
          end
        end

        # spacer for project titles, active project marked with *
        def active_indicator( project )
          indicator = project.current ? "* " : "  "
        end

        def tag_view tags, title_length
          spacer = [0, ViewRecords::Project.max_title_length - title_length].max
          view = "  " + ( " " * spacer )
          return  view + "tags: none" if tags.length < 1

          view += "tags: ["
          tags.each { |t| view += "#{t}, "}
          view[0..-3] + "]"
        end

        def project_block record
          record.format do |r|
            if @options[:verbose]
              @options[:id] = true
              @options[:tags] = true
            end
            @options[:active] = @options.fetch( :active, false )

            record = r.title

            id = @options[:id] ? "[#{r.id}] " : ""
            active = @options[:active] ? active_indicator( r ) : ""
            depth = @options[:depth] ? "  " * r.depth : ""
            title = r.title
            view = "#{id}#{active}#{depth}#{title}"
            tags = @options[:tags] ? tag_view( r.tags, view.length ) : ""
            view += tags
            puts view
          end
        end

        def timerecord_block record
          record.format do |r|
            running = r.running ? "*" : " "
            description = r.description.empty? ? "#{r.project}" : "#{r.project}: #{r.description}"
            view =  "#{r.start_time.strftime('%H:%M')} - #{r.end_time.strftime('%H:%M')}#{running} [#{r.duration.format}] #{description}"
            puts view
          end
        end
      end
    end
  end
end
