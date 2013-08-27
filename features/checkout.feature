Feature: Checkout Command manages the active project
  A New project can be added and checked out
  An Exiting project can be checked out

  Scenario: Checkout an existing project with checkout
    When I successfully run `tempo checkout "horticulture - backyard bonsai"`
    Then the stdout should contain "switched to project 'horticulture - backyard bonsai'"

  Scenario: Checkout an exising project with c
    When I successfully run `tempo c "horticulture - backyard bonsai"`
    Then the stdout should contain "switched to project 'horticulture - backyard bonsai'"

  Scenario: Checkout an existing project by partial match
    When I successfully run `tempo checkout "backyard bonsai"`
    Then the stdout should contain "switched to project 'horticulture - backyard bonsai'"

  Scenario: Attempting to Checkout an existing project by partial match with multiple possibilities
    When I successfully run `tempo checkout "horticulture"`
    Then the stdout should contain "multiple projects found:"
    And the stdout should contain "* horticulture - basement mushrooms"
    And the stdout should contain "  horticulture - backyard bonsai"

  Scenario: Attempting to Checkout the current project
    When I successfully run `tempo checkout "horticulture - basement mushrooms"`
    Then the stdout should contain "already on project 'horticulture - basement mushrooms'"

  Scenario: Attempting to checkout a non-existant project
    When I successfully run `tempo checkout "new project"`
    Then the stdout should contain "no projects match 'new project'"
    And the stdout should not contain "switched"

  Scenario: Adding and checking out a new project
    When I successfully run `tempo checkout --add "bathtup scuba diving"`
    Then the stdout should contain "switched to new project 'bathtup scuba diving'"
    And the project file should contain ":title: bathtup scuba diving"

  Scenario: Attempting to add an exising project
    When I run `tempo checkout --add "horticulture - basement mushrooms"`
    Then the stderr should contain "error: project 'horticulture - basement mushrooms' already exists"
