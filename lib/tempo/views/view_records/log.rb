module Tempo
  module Views
    module ViewRecords

      # Base Composite log class, used for extending views for any child of Tempo::Model::Log
      # Inherits the id, and type from ViewRecords::Model, and adds an start time and date_id.
      #
      #
      # The Log View Model is an abstract model that is extended to create views for children
      # of the Log Model class. See ViewRecords::TimeRecord for an example.
      #
      class Log < ViewRecords::Model
        attr_accessor :start_time, :d_id

        def initialize(model, options={})
          super model, options
          @start_time = model.start_time
          @d_id = model.d_id
        end

        def format(&block)
          block ||= lambda {|model| "#{ model.type.capitalize} #{model.d_id}-#{model.id} #{model.start_time.strftime('%H:%M')}"}
          block.call self
        end
      end
    end
  end
end
