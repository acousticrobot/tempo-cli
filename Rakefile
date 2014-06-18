require 'rake/clean'
require 'rubygems'
require 'rubygems/package_task'
require 'rdoc/task'
require 'cucumber'
require 'cucumber/rake/task'
require "fileutils"

Rake::RDocTask.new do |rd|
  rd.rdoc_files.include("lib/**/*.rb","bin/**/*")
  rd.title = 'tempo'
end

spec = eval(File.read('tempo-cli.gemspec'))

Gem::PackageTask.new(spec) do |pkg|
end
CUKE_RESULTS = 'features/results.html'
CLEAN << CUKE_RESULTS
desc 'Run features'
Cucumber::Rake::Task.new(:features) do |t|
  opts = "features --format html -o #{CUKE_RESULTS} --format progress -x"
  opts += ' --tags ~@pending'
  opts += " --tags #{ENV['TAGS']}" if ENV['TAGS']
  t.cucumber_opts =  opts
  t.fork = false
end

desc 'Run features tagged with focus (@focus)'
Cucumber::Rake::Task.new('cucumber:focus') do |t|
  tag_opts = ' --tags ~@pending'
  tag_opts += ' --tags @focus'
  t.cucumber_opts = "features --format html -o #{CUKE_RESULTS} --format pretty -x -s#{tag_opts}"
  t.fork = false
end

task :cucumber => :features

task :tests_setup do
  @ORIGINAL_HOME = ENV['HOME']
  ENV['HOME'] = ENV['HOME'] + "/testing"
  Dir.mkdir(ENV['HOME'], 0700) unless File.exists?(ENV['HOME'])
  dir = File.join(Dir.home,"tempo")
  Dir.mkdir(dir, 0700) unless File.exists?(dir)
end

task :tests_teardown do
  ENV['HOME'] = @ORIGINAL_HOME
  dir = File.join(Dir.home, "testing")
  FileUtils.rm_r dir if File.exists?(dir)
end

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.name = "run_tests"
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb']
end

task :test => [:tests_setup, :run_tests, :tests_teardown ]

task :clean => [:tests_setup, :tests_teardown]

task :default => [:tests_setup, :run_tests, :features, :tests_teardown]

task 'features:focus' => [:tests_setup, :run_tests, 'cucumber:focus']
