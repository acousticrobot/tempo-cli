# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','tempo','version.rb'])
spec = Gem::Specification.new do |s|
  s.name = 'tempo'
  s.version = Tempo::VERSION
  s.author = 'Jonathan Gabel'
  s.email = 'hello@jonathangabel.com'
  s.homepage = 'http://jonathangabel.com'
  s.platform = Gem::Platform::RUBY
  s.summary = 'A command line time tracker for recording by day or by project'
  s.description = 'Record and report time spent by project'
# Add your other files here if you make them
# Add lib files to lib.tempo.rb
  s.files = %w(
    bin/tempo
    lib/tempo/version.rb
    lib/tempo.rb
  )
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.bindir = 'bin'
  s.executables << 'tempo'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
  s.add_development_dependency('turn', '~> 0.9.6')
  s.add_development_dependency('pry','~> 0.9.12.2')
  s.add_runtime_dependency('gli','2.6.1')
  s.add_runtime_dependency "chronic", "~> 0.10.2"
end
