require "spec_helper"


# Check unique methods of class with instance_methods(false)
# example: Tempo::Project.instance_methods(false)
# => [:id, :id=, :title, :title=, :tags, :tags=, :sub_projects, :sub_projects=]
#
def has_accessor?( obj, attribute, opt = {} )
  opt[:readable] ||= true
  opt[:writeable]||= false
  attribute_writer = ( attribute.to_s + "=" ).to_sym
  is_readable = obj.class.instance_methods(false).include?(attribute)
  is_writable = obj.class.instance_methods(false).include?(attribute_writer)
  if !opt[:readable]
    return is_writable
  elsif !opt[:writeable]
    return is_readable
  end
  is_readable && is_writable
end


# example:
# subject { my_class_instance }
# it { should_not be_accessible :field_name }
# it { should be_accessible :field_name }
#
RSpec::Matchers.define :have_accessor do |attribute|
  match do |response|
    has_accessor?( response, attribute )
  end
  description { "be accessible :#{attribute}" }
  failure_message_for_should { ":#{attribute} should be accessible" }
  failure_message_for_should_not { ":#{attribute} should not be accessible" }
end


RSpec::Matchers.define :have_readable do |attribute|
  match do |response|
    has_accessor?( response, attribute, writeable: false )
  end
  description { "be readable:#{attribute}" }
  failure_message_for_should { ":#{attribute} should be readable" }
  failure_message_for_should_not { ":#{attribute} should not be readable" }
end

RSpec::Matchers.define :have_writeable do |attribute|
  match do |response|
    has_accessor?( response, attribute, readable: false )
  end
  description { "be writeable :#{attribute}" }
  failure_message_for_should { ":#{attribute} should be writeable" }
  failure_message_for_should_not { ":#{attribute} should not be writeable" }
end