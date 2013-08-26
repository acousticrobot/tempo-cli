require "test_helper"

describe Tempo do

  describe "Views" do

    describe "projects list" do
      it "should return formatted projects" do

      project_array = [ 'a', 'b', 'c', 'd' ]
      current_project = 'b'
      view = Tempo::Views::projects_list project_array, current_project, false
      view.must_equal [ "  a", "* b", "  c", "  d" ]
      end
    end
  end
end