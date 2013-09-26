When /^I get help for "([^""]*)"$/ do |app_name|
  @app_name = app_name
  step %(I run `#{app_name} help`)
end

Given /^a clean installation$/ do
    @testing_env = File.join( ENV['HOME'], 'tempo' )
    FileUtils.rm_r( @testing_env ) if File.exists?( @testing_env )
end

Given /^an existing project file$/ do
  @testing_env = File.join( ENV['HOME'], 'tempo' )
  Dir.mkdir( @testing_env, 0700 ) unless File.exists?( @testing_env )
  projects_file = File.join( @testing_env, 'tempo_projects.yaml' )

  File.open( projects_file,'w' ) do |f|
    projects = ["---", ":id: 1", ":parent: :root", ":children:", "- 2", "- 3", ":title: horticulture", ":tags:", "- cultivation", ":current: true",
                "---", ":id: 2", ":parent: 1", ":children: []", ":title: backyard bonsai", ":tags:", "- miniaturization", "- outdoors",
                "---", ":id: 3", ":parent: 1", ":children: []", ":title: basement mushrooms", ":tags:", "- fungi", "- indoors",
                "---", ":id: 4", ":parent: :root", ":children:", "- 5", "- 6", ":title: aquaculture", ":tags:", "- cultivation",
                "---", ":id: 5", ":parent: 4", ":children: []", ":title: nano aquarium", ":tags:", "- miniaturization",
                "---", ":id: 6", ":parent: 4", ":children: []", ":title: reading aquaculture digest", ":tags: []"]

    projects.each do |p|
      f.puts p
    end
  end
end

Then /^the time record (.*?) should contain "(.*?)" at line (\d+)$/ do |arg1, arg2, arg3|
  file = File.join( ENV['HOME'], 'tempo/tempo_time_records', "#{arg1}.yaml")
  contents = []
  File.open(file, "r") do |f|
    f.readlines.each do |line|
      contents << line.chomp
    end
  end
  contents[arg3.to_i - 1].should include arg2
end

Then /^the (.*?) file should contain "(.*?)" at line (\d+)$/ do |arg1, arg2, arg3|
  file = File.join( ENV['HOME'], 'tempo', "tempo_#{arg1}s.yaml")
  contents = []
  File.open(file, "r") do |f|
    f.readlines.each do |line|
      contents << line.chomp
    end
  end
  contents[arg3.to_i - 1].should include arg2
end

Then /^the (.*?) file should contain "(.*?)"$/ do |arg1, arg2|
  file = File.join( ENV['HOME'], 'tempo', "tempo_#{arg1}s.yaml")
  contents = []
  File.open(file, "r") do |f|
    f.readlines.each do |line|
      contents << line.chomp
    end
  end
  contents.should include arg2
end

Then /^the (.*?) file should not contain "(.*?)"$/ do |arg1, arg2|
  file = File.join( ENV['HOME'], 'tempo', "tempo_#{arg1}s.yaml")
  contents = []
  File.open(file, "r") do |f|
    f.readlines.each do |line|
      contents << line.chomp
    end
  end
  contents.should_not include arg2
end
