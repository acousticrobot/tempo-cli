module Tempo
  class Project < Tempo::Model
    attr_accessor :title, :tags
    @current = 0

    class << self

      def current( instance_id=nil )
        return @current unless instance_id
        if instance_id.kind_of? Integer and ids.include? instance_id
          @current = instance_id
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
      self.class.current(self.id) if current
    end

    def freeze_dry
      record = super
      if self.class.current == @id
        record[:current] = true
      end
      record
    end

    def to_s
      puts "id: #{id}, title: #{title}, tags: #{tags}"
    end
  end
end
