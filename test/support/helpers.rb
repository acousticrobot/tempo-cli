def eval_file_as_array( file )
  contents = []
  File.open(file, "r") do |f|
    f.readlines.each do |line|
      contents << line.chomp
    end
  end
  contents
end

def has_attr_reader?(obj, attribute)
  obj.class.instance_methods(false).include?(attribute)
end

def has_attr_writer?(obj, attribute)
  attribute_writer = ( attribute.to_s + "=" ).to_sym
  is_writable = obj.class.instance_methods(false).include?(attribute_writer)
end

def has_attr_accessor?( obj, attribute)
  has_attr_reader?(obj, attribute) && has_attr_writer?(obj, attribute)
end

def has_attr_read_only?( obj, attribute)
  has_attr_reader?(obj, attribute) && !has_attr_writer?(obj, attribute)
end