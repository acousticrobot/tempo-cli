module Tempo
  module Controllers
    class Start < Tempo::Controllers::Base
      @projects = Model::Project

      class << self

        def start_timer( options, args )
        end

      end #class << self
    end
  end
end
