require "test_helper"

describe Tempo do
  describe "Views" do

    describe "project list view" do
      it "should return all formatted projects by default" do
        project_factory
        view = Tempo::Views::projects_list_view({ output: false })
        view.must_equal [ "  gardening", "    horticulture - backyard bonsai", "*   horticulture - basement mushrooms", "  sheep herding" ]
      end

      it "should be able to return a subset of projects" do
        project_factory
        subset = Tempo::Model::Project.index[1..3]
        view = Tempo::Views::projects_list_view({ projects: subset, output: false })
        view.must_equal [ "  gardening", "    horticulture - backyard bonsai", "*   horticulture - basement mushrooms" ]
      end
    end
  end
end