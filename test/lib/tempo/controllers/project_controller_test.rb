require "test_helper"

describe Tempo::Controllers::Projects do
  describe "Class Methods" do

    before do
      @controller = Tempo::Controllers::Projects
    end

    describe "exact match" do

      before do
        project_factory
        Tempo::Model::Project.new title: 'horticulture'
      end

      it "should find an exact match" do
        match1 = @controller.filter_projects_by_title({ exact: true }, ["horticulture"])
        match1.length.must_equal 1
        match1[0].title.must_equal "horticulture"
      end
    end
  end
end