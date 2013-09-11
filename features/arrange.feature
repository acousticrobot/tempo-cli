Feature: Arrange Command manages the hierarchy of a list of projects
  Projects can be ordered as root projects or children of other projects
  The arrange command manages the relationship between parentg and child projects

  Scenario: Arranging a project as a root projects
    Given an existing project file
    When I successfully run `tempo arrange : basement mushrooms`
    Then the stdout should contain "root project: basement mushrooms"
    And the project file should contain ":parent: :root" at line 20

  Scenario: Arranging a project as a child of another project
    Given an existing project file
    When I successfully run `tempo arrange horticulture : nano aquarium`
    Then the stdout should contain "parent project: horticulture"
    And the stdout should contain "child project: nano aquarium"
    And the project file should contain ":parent: 1" at line 39
    And the project file should contain "- 5" at line 7

  Scenario: Attempting to arrange projects without using a colon in the args
    Given an existing project file
    When I run `tempo arrange horticulture aquaculture`
    Then the stderr should contain "arrange requires a colon (:) in the arguments"

  Scenario: Attempting to arrange a root project as a root project
    Given an existing project file
    When I run `tempo arrange : horticulture`
    Then the stdout should contain "horticulture is already a root project"

  Scenario: Arranging projects by id
    Given an existing project file
    When I successfully run `tempo arrange -i 4 : 1`
    Then the stdout should contain "parent project: aquaculture"
    And the stdout should contain "child project: horticulture"
    And the project file should contain ":parent: 4" at line 3
    And the project file should contain "- 1" at line 31

  Scenario: Arranging projects by exact match
    Given an existing project file
    When I successfully run `tempo arrange -e reading aquaculture digest : aquaculture`
    Then the stdout should contain "parent project: reading aquaculture digest"
    And the stdout should contain "child project: aquaculture"
    And the project file should contain ":parent: 6" at line 29
    And the project file should contain "- 4" at line 47