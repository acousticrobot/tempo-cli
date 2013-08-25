require 'aruba/cucumber'

ENV['PATH'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../bin')}#{File::PATH_SEPARATOR}#{ENV['PATH']}"
LIB_DIR = File.join(File.expand_path(File.dirname(__FILE__)),'..','..','lib')

Before do

  ## Using "announce" causes massive warnings on 1.9.2
  # @puts = true
  # @original_rubylib = ENV['RUBYLIB']
  # ENV['RUBYLIB'] = LIB_DIR + File::PATH_SEPARATOR + ENV['RUBYLIB'].to_s

  # switch home environment for testing in Rakefile
  # example for doing this within cucumber:
  #
  # @real_home = ENV['HOME']
  # testing_env = File.join(ENV['HOME'],'.testing', 'features')
  # FileUtils.rm_rf testing_env, :secure => true
  # Dir.mkdir(testing_env, 0700)
  # ENV['HOME'] = testing_env
end

After do
  # ENV['HOME'] = @real_home
end
