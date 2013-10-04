require "test_helper"

describe Tempo do
  describe "Views" do

    describe "report view" do
      it "should return all formatted projects by default" do
        project_factory
        view = Tempo::Views::projects_list_view({ output: false })
        view.must_equal [ "  horticulture - backyard bonsai", "* horticulture - basement mushrooms", "  sheep herding" ]
      end

      it "should be able to return a subset of projects" do
        project_factory
        subset = Tempo::Model::Project.index[0..1]
        view = Tempo::Views::projects_list_view({ projects: subset, output: false })
        view.must_equal [ "* horticulture - basement mushrooms", "  sheep herding" ]
      end
    end
  end
end