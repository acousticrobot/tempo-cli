module Tempo
  module Views
    module ViewRecords

      # Project ViewRecords adds the project title, any tags, and a
      # duration to the composite model.  It also keeps track of the
      # maximum title length of all Project views.
      #
      class Project < ViewRecords::Composite
        attr_accessor :title, :tags, :current, :duration

        class << self
          def max_title_length len=0
            @max_title_length ||= 0
            @max_title_length = @max_title_length > len ? @max_title_length : len
          end
        end

        def initialize model, options={}
          super model, options
          @title = model.title
          @tags = model.tags
          @current = model.current?
          @duration = Duration.new
          self.class.max_title_length @title.length
        end
      end
    end
  end
end