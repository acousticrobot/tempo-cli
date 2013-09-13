# Add requires for other files you add to your project here, so
# you just need to require this one file in your bin file
require 'tempo/version.rb'
require 'tempo/views.rb'

require 'tempo/models/base.rb'
require 'tempo/models/composite.rb'
require 'tempo/models/log.rb'
Dir[File.dirname(__FILE__) + '/tempo/models/*.rb'].each {|file| require file }

require 'tempo/controllers/base.rb'
Dir[File.dirname(__FILE__) + '/tempo/controllers/*.rb'].each {|file| require file }

require 'file_record/directory.rb'
require 'file_record/record.rb'
