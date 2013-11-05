# ViewRecords are simplified models, with additional display information, used in views.
#
# Each viewrecord has a :type, which can be queried in the view to know
# what type of record it is managing.
#
# They also each have a format method, which accept a block, and also includes a default
# block which returns a basic formatted string.
#
# ViewRecords can be nested, for instance the Time ViewRecords contain
# a Duration ViewRecord.
#
# View records should add themselves to the Reporter on init, with the exception of
# partials (such as duration), which are managed within other view records
#
# They have no logic, and so it is up
# to the creation method to make sure they are a correct copy of the information
# they are representing.

module Tempo
  module Views

    class InvalidViewRecordError < Exception
    end

    module ViewRecords

      # The most simple view records, with a message string
      # and a category, which defaults to :info. Categories
      # can be used for color / logging diferentiation.
      # category :error will raise an error after all viewRecords
      # have been run through the reporters
      #
      class Message
        attr_accessor :type, :message, :category

        def initialize message, options={}
          @message = message
          @category = options.fetch( :category, :info )
          @type = "message"
          Reporter.add_view_record self
        end

        def format &block
          block ||= lambda {|m| "#{m.message}"}
          block.call self
        end
      end

      # Specifically for managing a time duration, nested in other
      # view records. This can be used with a start and end time,
      # or used to manage a sum of times.
      #
      # Total duration is stored in seconds.
      #
      # Duration records can be further queried for hours and minutes
      # in order to construct a human redable duration.
      # This can be used to construct time as #{hours}:#{minutes}
      # Hours returns the total whole hours, minutes returns the remaining
      # whole minutes after the hours have been removed from the total.
      #
      class Duration
        attr_accessor :type, :total

        def initialize seconds=0
          @type = "duration"
          @total = seconds
        end

        def format &block
          block ||= lambda do |d|
            "#{ d.hours.to_s }:#{ d.minutes.to_s.rjust(2, '0') }"
          end
          block.call self
        end

        def add seconds
          @total += seconds
        end

        def subtract seconds
          @total -= seconds
        end

        def hours
          hours = ( @total / 3600 ).to_i
        end

        def minutes
          minutes = ( @total / 60 - hours * 60 ).to_i
        end
      end

      # Base model class, used for extending views for any child of Tempo::Model::Base
      # Sets the id, and type, where type is the class type of the model, for example
      # "project" for Tempo::Model::Project. ViewReord::Model should handle any type of
      # tempo model without error, but most likely won't be as useful as a child class
      # taylored to the specifics of the actual model's child class.
      #
      class Model
        attr_accessor :id, :type

        def initialize model, options={}
          @id = model.id

          # example: Tempo::Model::Something => "something"
          @type = /Tempo::Model::(.*)$/.match( model.class.to_s )[1].downcase
          Reporter.add_view_record self
        end

        def format &block
          block ||= lambda {|model| "#{ model.type.capitalize} #{model.id}"}
          block.call self
        end
      end
    end
  end
end