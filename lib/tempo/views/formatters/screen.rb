# Tempo View Formatters are triggered by the View Reporter, and all inherit from
# Views::Base
#
# The screen formatter is the primary formatter for reporting results back to the
# screen. All formatting is handled after the main processes, when the Reporter is
# invoked during the post block. (If immediate feedback is needed,
# see Formatters::Console)

module Tempo
  module Views
    module Formatters

      class Screen < Tempo::Views::Formatters::Base

        def message_block(record)
          record.format do |m|
            case m.category
            when :error
              raise m.message
            when :info, :warning, :debug
              puts m.message
            end
            m.message
          end
        end

        def duration_block(record)
          record.format do |d|
            puts "#{ d.hours.to_s }:#{ d.minutes.to_s.rjust(2, '0') }"
          end
        end

# PARTIALS vv-----------------------------------------------------------------vv

        # spacer for project titles, active project marked with *
        def active_indicator(project)
          indicator = project.current ? "* " : "  "
        end

        def tag_partial(tags, title_length)
          max_length = ViewRecords::Project.max_title_length
          max_length += ViewRecords::Project.max_depth * 2 if @options[:depth]
          max_length += 6 if @options[:id]
          max_length += 2 if @options[:active]
          spacer = [0, max_length - title_length].max
          view = "  " + ( " " * spacer )
          return  view + "tags: none" if tags.length < 1

          view += "tags: ["
          tags.each { |t| view += "#{t}, "}
          view[0..-3] + "]"
        end

        def id_partial(id)
          @options[:id] ? "[#{id}] ".rjust(6, ' ') : ""
        end

# PARTIALS ^^-----------------------------------------------------------------^^


        def project_block(record)

          record.format do |r|
            @options[:active] = @options.fetch( :active, false )
            record = r.title

            id = id_partial r.id
            active = @options[:active] ? active_indicator( r ) : ""
            depth = @options[:depth] ? "  " * r.depth : ""
            title = r.title
            view = "#{id}#{active}#{depth}#{title}"
            tags = @options[:tags] ? tag_partial( r.tags, view.length ) : ""
            view += tags
            puts view
          end
        end

        def timerecord_block(record)
          #require 'pry'; binding.pry
          record.format do |r|
            id = id_partial r.id
            running = r.running ? "*" : " "
            if @options[:bullet_report]
              view =  " * #{r.description}"
            else
              description = r.description.empty? ? "#{r.project}" : "#{r.project}: #{r.description}"
              view =  "#{id}#{r.start_time.strftime('%H:%M')} - #{r.end_time.strftime('%H:%M')}#{running} [#{r.duration.format}] #{description}"
            end
            puts view
          end
        end
      end
    end
  end
end
