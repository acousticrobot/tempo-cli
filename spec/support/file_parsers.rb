def eval_file_as_array( file )
  contents = []
  File.open(file, "r") do |f|
    f.readlines.each do |line|
      contents << line.chomp
    end
  end
  contents
end
