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
  FileUtils.rm_r( @testing_env ) if File.exists?( @testing_env )
  Dir.mkdir( @testing_env, 0700 )
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

Given /^an existing time record file$/ do
  @records_directory = File.join( ENV['HOME'], 'tempo/tempo_time_records' )
  FileUtils.rm_r( @records_directory ) if File.exists?( @records_directory )
  Dir.mkdir( @records_directory, 0700 )
  projects_file = File.join( @records_directory, '20140101.yaml' )

  File.open( projects_file,'w' ) do |f|
    records = [ ":description: putting on overalls and straw hat",
                ":start_time: 2014-01-01 05:00:00.000000000 -05:00",
                ":end_time: 2014-01-01 05:15:00.000000000 -05:00",
                ":id: 1",
                ":project: 1",
                ":tags: []",
                "---",
                ":project_title: backyard bonsai",
                ":description: trimming the trees",
                ":start_time: 2014-01-01 05:15:00.000000000 -05:00",
                ":end_time: 2014-01-01 08:15:00.000000000 -05:00",
                ":id: 2",
                ":project: 2",
                ":tags: []",
                "---",
                ":project_title: backyard bonsai",
                ":description: mixing up a batch of potting soil",
                ":start_time: 2014-01-01 08:15:00.000000000 -05:00",
                ":end_time: 2014-01-01 10:38:00.000000000 -05:00",
                ":id: 3",
                ":project: 2",
                ":tags: []",
                "---",
                ":project_title: aquaculture",
                ":description: putting on the wetsuit",
                ":start_time: 2014-01-01 12:52:00.000000000 -05:00",
                ":end_time: 2014-01-01 13:26:00.000000000 -05:00",
                ":id: 4",
                ":project: 4",
                ":tags: []",
                "---",
                ":project_title: nano aquarium",
                ":description: trimming the coral",
                ":start_time: 2014-01-01 13:32:00.000000000 -05:00",
                ":end_time: 2014-01-01 16:46:00.000000000 -05:00",
                ":id: 5",
                ":project: 5",
                ":tags: []" ]
    records.each do |p|
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

Then /^the time record (.*?) should not contain "(.*?)"$/ do |arg1, arg2|
  file = File.join( ENV['HOME'], 'tempo/tempo_time_records', "#{arg1}.yaml")
  contents = []
  File.open(file, "r") do |f|
    f.readlines.each do |line|
      contents << line.chomp
    end
  end
  contents.should_not include arg2
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
