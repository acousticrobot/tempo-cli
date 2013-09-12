Feature: Checkout Command manages the active project
  A New project can be added and checked out
  An Exiting project can be checked out

  Scenario: Checkout an existing project with checkout
    Given an existing project file
    When I successfully run `tempo checkout "backyard bonsai"`
    Then the stdout should contain "switched to project: backyard bonsai"
    And the project file should contain ":current: true" at line 18

  Scenario: Checkout an exising project with c
    Given an existing project file
    When I successfully run `tempo c "backyard bonsai"`
    Then the stdout should contain "switched to project: backyard bonsai"
    And the project file should contain ":current: true" at line 18

  Scenario: Checkout an existing project by partial match
    Given an existing project file
    When I successfully run `tempo checkout "bonsai"`
    Then the stdout should contain "switched to project: backyard bonsai"
    And the project file should contain ":current: true" at line 18

  Scenario: Checkout a project by id
    Given an existing project file
    When I successfully run `tempo checkout -i 3`
    Then the stdout should contain "switched to project: basement mushrooms"

  Scenario: Checkout a project by exact match
    Given an existing project file
    And I successfully run `tempo checkout -e aquaculture`
    Then the stdout should contain "switched to project: aquaculture"
    And the stdout should not contain "switched to project: reading aquaculture digest"

  Scenario: Attempting to Checkout an existing project by partial match with multiple possibilities
    Given an existing project file
    And I run `tempo checkout aquaculture`
    Then the stdout should contain "The following projects matched your search:"
    And the stdout should contain "  aquaculture"
    And the stdout should contain "  reading aquaculture digest"
    And the stderr should contain "error: cannot checkout multiple projects"

  Scenario: Attempting to Checkout the current project
    Given an existing project file
    When I successfully run `tempo checkout "horticulture"`
    Then the stdout should contain "already on project: horticulture"

  Scenario: Attempting to checkout a non-existant project
    Given an existing project file
    When I run `tempo checkout "new project"`
    And the stdout should not contain "switched"
    Then the stderr should contain "no projects match the request: new project"

  Scenario: Adding and checking out a new project
    Given an existing project file
    When I successfully run `tempo checkout --add "bathtup scuba diving"`
    Then the stdout should contain "switched to new project: bathtup scuba diving"
    And the project file should contain ":title: bathtup scuba diving"
    And the project file should contain ":current: true"

  Scenario: Attempting to add an exising project
    Given an existing project file
    When I run `tempo checkout --add "basement mushrooms"`
    Then the stderr should contain "error: project 'basement mushrooms' already exists"
