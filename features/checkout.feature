Feature: Checkout Command manages the active project
  A New project can be added and checked out
  An Exiting project can be checked out

  Scenario: Checkout an exising project with checkout
    When I successfully run `tempo checkout "horticulture - backyard bonsai"`
    Then the stdout should contain "Switched to project 'horticulture - backyard bonsai'"

  Scenario: Checkout an exising project with co
    When I successfully run `tempo checkout "horticulture - backyard bonsai"`
    Then the stdout should contain "Switched to project 'horticulture - backyard bonsai'"

  Scenario: Checkout an existing project by partial match
    When I successfully run `tempo checkout "backyard bonsai"`
    Then the stdout should contain "Switched to project 'horticulture - backyard bonsai'"

  Scenario: Attempting to Checkout an existing project by partial match with multiple possibilities
    When I successfully run `tempo checkout "horticulture"`
    Then the stdout should contain "Multiple projects found:"
    And the stdout should contain "  horticulture - basement mushrooms"
    And the stdout should contain "  horticulture - backyard bonsai"

  Scenario: Attempting to Checkout the current project
    When I successfully run `tempo checkout "horticulture - basement mushrooms"`
    Then the stdout should contain "Already on 'horticulture - basement mushrooms'"

  Scenario: Attempting to checkout a non-existant project
    When I run `tempo checkout "new project"`
    Then the stderr should contain "error: no project 'new project' exists"
    And the stdout should not contain "changed"

  Scenario: Adding and checking out a new project
    When I successfully run `tempo checkout --add "bathtup scuba diving"`
    Then the stdout should contain "Switched to a new branch 'bathtub scuba diving'"