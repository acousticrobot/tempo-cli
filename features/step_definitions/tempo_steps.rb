When /^I get help for "([^""]*)"$/ do |app_name|
  @app_name = app_name
  step %(I run `#{app_name} help`)
end

Given /^An existing project file$/ do
  @testing_env = File.join( ENV['HOME'], '.tempo' )
  Dir.mkdir( @testing_env, 0700 ) unless File.exists?( @testing_env )
  projects_file = File.join( @testing_env, 'tempo_projects.yaml' )

  File.open( projects_file,'w' ) do |f|
    projects = [ "---", ":id: 1", ":title: sheep hearding", ":tags: []",

                 "---", ":id: 2", ":title: horticulture - basement mushrooms",
                    ":tags:", "- fungi", "- farming",

                 "---", ":id: 3", ":title: horticulture - backyard bonsai",
                    ":tags:", "- trees", "- farming", "- miniaturization"
                ]

    projects.each do |p|
      f.puts p
    end
  end
end

Then /^the (.*?) file should contain "(.*?)"$/ do |arg1, arg2|
  file = File.join( ENV['HOME'], '.tempo', "tempo_#{arg1}s.yaml")
  contents = []
  File.open(file, "r") do |f|
    f.readlines.each do |line|
      contents << line.chomp
    end
  end
  contents.should include arg2
end

Then /^the (.*?) file should not contain "(.*?)"$/ do |arg1, arg2|
  file = File.join( ENV['HOME'], '.tempo', "tempo_#{arg1}s.yaml")
  contents = []
  File.open(file, "r") do |f|
    f.readlines.each do |line|
      contents << line.chomp
    end
  end
  contents.should_not include arg2
end