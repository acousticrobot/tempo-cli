# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','tempo','version.rb'])
spec = Gem::Specification.new do |s|
  s.name = 'tempo-cli'
  s.version = Tempo::VERSION
  s.author = 'Jonathan Gabel'
  s.email = 'hello@jonathangabel.com'
  s.license = 'MIT'
  s.homepage = 'https://github.com/josankapo/tempo-cli'
  s.platform = Gem::Platform::RUBY
  s.summary = 'A command line time tracker for recording by day and by project'
  s.description = 'tempo-cli is a command line time tracking application.  Record time spent on projects in YAML files, and manage them from the command line.'
  s.files = `git ls-files`.split("\n")
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.bindir = 'bin'
  s.executables << 'tempo'
  s.add_development_dependency('rake', '~> 10.3')
  s.add_development_dependency('rdoc', '~> 4.1')
  s.add_development_dependency('aruba', '~> 0.5')
  s.add_development_dependency('turn', '~> 0.9')
  s.add_development_dependency('pry','~> 0.9')
  s.add_runtime_dependency('gli', '~> 2.10')
  s.add_runtime_dependency "chronic", "~> 0.10"
end
