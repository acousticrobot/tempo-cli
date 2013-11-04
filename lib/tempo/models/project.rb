module Tempo
  module Model
    class Project < Tempo::Model::Composite
      attr_accessor :title
      attr_reader :tags
      @current = 0

      class << self

        def current( instance=nil )
          @current
        end

        def current=( instance )
          if instance.class == self
            @current = instance
          else
            raise ArgumentError
          end
        end

        def include?( title )
          matches = find_by_title( title )
          return false if matches.empty?
          matches.each do |match|
            return true if match.title == title
          end
          false
        end
      end

      def initialize(options={})
        super options
        @title = options.fetch(:title, "new project")
        @tags = []
        tag options.fetch(:tags, [])
        current = options.fetch(:current, false)
        self.class.current = self if current
      end

      def current?
        self.class.current == self
      end

      def freeze_dry
        record = super
        if self.class.current == self
          record[:current] = true
        end
        record
      end

      def tag( tags )
        return unless tags and tags.kind_of? Array
        tags.each do |tag|
          tag.split.each {|t| @tags << t if ! @tags.include? t }
        end
        @tags.sort!
      end

      def untag( tags )
        return unless tags and tags.kind_of? Array
        tags.each do |tag|
          tag.split.each {|t| @tags.delete t }
        end
      end

      def to_s
        puts "id: #{id}, title: #{title}, tags: #{tags}"
      end
    end
  end
end
