require "spec_helper"
require 'tempo.rb'
require 'pry'

describe "Projects" do
  p = Tempo::Project.new
  describe "accessible methods" do
    subject { p }
    it { should have_accessor :id }
    it { should have_accessor :title }
    it { should have_accessor :tags }
    it { should have_accessor :sub_projects }
  end
end