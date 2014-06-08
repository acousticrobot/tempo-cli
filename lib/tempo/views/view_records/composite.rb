module Tempo
  module Views
    module ViewRecords

      # Base Composite model class, used for extending views for any child of Tempo::Model::Composite
      # Inherits the id, and type from ViewRecords::Model, and adds an integer depth to hold the depth
      # within the tree structure of the Composite model. It is important to note, the ViewRecord has
      # no way of determining the depth of the model it represents, and this must be supplied to the
      # instance on instantiation, or after.
      #
      # The Composite ViewRecord class also keeps track of the max depth of all of it's members, this
      # can be used to calculate the padding added to any views.
      #
      # The Composite View Model is an abstract model that is extended to create views for children
      # of the Composite Model class. See ViewRecords::Project for an example.
      #
      class Composite < ViewRecords::Model
        attr_accessor :depth

        class << self
          def max_depth(depth=0)
            @max_depth ||= 0
            @max_depth = @max_depth > depth ? @max_depth : depth
          end
        end

        def initialize(model, options={})
          super model, options
          @depth = options.fetch(:depth, 0)
          self.class.max_depth @depth
        end

        def format(&block)
          block ||= lambda {|model| "#{"  " * model.depth}#{ model.type.capitalize} #{model.id}"}
          block.call self
        end
      end
    end
  end
end
