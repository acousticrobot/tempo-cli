Feature: Global Directory Command allows for an alternate directory location
  The default directory is located in the home directory
  Adding a directory arguement will run all commands on that path within the home directory

Scenario: Adding the first project in and alternate directory creates the subdirectory and file
  Given a clean installation
  When I successfully run `tempo --directory alt_dir project horticulture`
  Then the alternate directory project file should contain ":title: horticulture" at line 5
  And the alternate directory project file should contain "current" at line 7

