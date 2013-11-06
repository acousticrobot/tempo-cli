require "test_helper"

describe Tempo do
  describe "Views" do

    before do
      project_factory
      Tempo::Views::Reporter.clear_records
    end

    describe "project list view" do

      it "adds projects to reporter by default" do
        Tempo::Views::projects_list_view

        view = []
        Tempo::Views::Reporter.view_records.each {|r| view << r.title}
        view.must_equal [ "gardening", "horticulture - backyard bonsai", "horticulture - basement mushrooms", "sheep herding" ]
      end

      it "should be able to return a subset of projects" do
        subset = Tempo::Model::Project.index[1..3]
        Tempo::Views::projects_list_view subset

        view = []
        Tempo::Views::Reporter.view_records.each {|r| view << r.title}
        view.must_equal [ "gardening", "horticulture - backyard bonsai", "horticulture - basement mushrooms" ]
      end
    end
  end
end