Feature: Global Directory Command allows for an alternate directory location
  The default directory is located in the home directory
  Adding a directory arguement will run all commands to that subdirectory within the home directory
  Features that save to a file will save to the new sub-directory

  Scenario: Adding the first project in an alternate directory creates the subdirectory and file
    Given a clean installation
    When I successfully run `tempo --directory alt_dir project horticulture`
    Then the alternate directory project file should contain ":title: horticulture" at line 5
    And the alternate directory project file should contain "current" at line 7

  @focus
  Scenario: Deleting a project by full match in and alternate directory
    Given an alternate directory and an existing project file
    When I successfully run `tempo --directory alt_dir project --delete "backyard bonsai"`
    Then the stdout should contain "deleted project:\nbackyard bonsai"
    And the alternate directory project file should not contain ":title: backyard bonsai"

  @focus
  Scenario: Tagging a project with a tag
    Given an alternate directory and an existing project file
    When I successfully run `tempo --directory alt_dir project backyard bonsai -t patience`
    Then the stdout should contain "backyard bonsai"
    And the stdout should contain "tags: [miniaturization, outdoors, patience]"
    And the alternate directory project file should contain "- patience"


