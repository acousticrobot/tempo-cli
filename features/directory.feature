@focus
Feature: Global Directory Command allows for an alternate directory location
  The default directory is located in the home directory
  Adding a directory arguement will run all commands to that subdirectory within the home directory
  Features that save to a file will save to the new sub-directory

  Scenario: Adding the first project in an alternate directory creates the subdirectory and file
    Given a clean installation
    When I successfully run `tempo --directory alt_dir project horticulture`
    Then the alternate directory project file should contain ":title: horticulture" at line 5
    And the alternate directory project file should contain "current" at line 7

  Scenario: Deleting a project by full match in an alternate directory
    Given an alternate directory and an existing project file
    When I successfully run `tempo --directory alt_dir project --delete "backyard bonsai"`
    Then the stdout should contain "deleted project:\nbackyard bonsai"
    And the alternate directory project file should not contain ":title: backyard bonsai"

  Scenario: Tagging a project with a tag in an alternate directory
    Given an alternate directory and an existing project file
    When I successfully run `tempo --directory alt_dir project backyard bonsai -t patience`
    Then the stdout should contain "backyard bonsai"
    And the stdout should contain "tags: [miniaturization, outdoors, patience]"
    And the alternate directory project file should contain "- patience"

  Scenario: Arranging a project as a root projects in an alternate directory
    Given an alternate directory and an existing project file
    When I successfully run `tempo --directory alt_dir arrange : basement mushrooms`
    Then the stdout should contain "root project:\nbasement mushrooms"
    And the alternate directory project file should contain ":parent: :root" at line 20

  Scenario: Arranging a project as a child of another project in an alternate directory
    Given an alternate directory and an existing project file
    When I successfully run `tempo --directory alt_dir arrange horticulture : nano aquarium`
    Then the stdout should contain "parent project:\nhorticulture"
    And the stdout should contain "child project:\nnano aquarium"
    And the alternate directory project file should contain ":parent: 1" at line 39
    And the alternate directory project file should contain "- 5" at line 7

  Scenario: Checkout an existing project with checkout in an alternate directory
    Given an alternate directory and an existing project file
    When I successfully run `tempo --directory alt_dir checkout "backyard bonsai"`
    Then the stdout should contain "switched to project:\nbackyard bonsai"
    And the alternate directory project file should contain ":current: true" at line 18

  Scenario: Adding and checking out a new project in an alternate directory
    Given an alternate directory and an existing project file
    When I successfully run `tempo --directory alt_dir checkout --add "bathtup scuba diving"`
    Then the stdout should contain "switched to project:\nbathtup scuba diving"
    And the alternate directory project file should contain ":title: bathtup scuba diving"
    And the alternate directory project file should contain ":current: true"

  Scenario: Adding a time record in an alternate directory
    Given an alternate directory and an existing project file
    When I run `tempo --directory alt_dir start --at "1-1-2014 7:00"`
    Then the stdout should contain "time record started"
    And the alternate directory time record 20140101 should contain ":start_time: 2014-01-01 08:00:00"


