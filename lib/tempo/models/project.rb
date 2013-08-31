module Tempo
  module Model
    class Project < Tempo::Model::Base
      attr_accessor :title, :tags
      @current = 0

      class << self

        def current( instance=nil )
          return @current unless instance
          if instance.class == self
            @current = instance
          else
            raise ArgumentError
          end
        end

        def list
          titles = []
          index.each do |p|
            titles << p.title
          end
         titles.sort!
        end
      end

      def initialize(params={})
        super params
        @title = params.fetch(:title, "new project")
        @tags = params.fetch(:tags, [])
        current = params.fetch(:current, false)
        self.class.current(self) if current
      end

      def freeze_dry
        record = super
        if self.class.current == self
          record[:current] = true
        end
        record
      end

      def to_s
        puts "id: #{id}, title: #{title}, tags: #{tags}"
      end
    end
  end
end
