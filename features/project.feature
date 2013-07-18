Feature: Project Command manages a list of projects
  The project command allows time to be tracked by project
  New projects can be added and deleted
  Projects can also be tagged as inactive or inactive

  Scenario: Listing all projects alphabetically by default
    When I successfully run `tempo project`
    Then the stdout should contain "* horticulture - basement mushrooms\n  sheep hearding\n"

  Scenario: Listing all Projects with --list
    When I successfully run `tempo project --list`
    Then the stdout should contain "  sheep hearding"
    And the stdout should contain "* horticulture - basement mushrooms"
    And the stdout should contain "  horticulture - backyard bonsai"

  Scenario: Listing all Projects with --l
    When I successfully run `tempo project -l`
    Then the stdout should contain "  sheep hearding"
    And the stdout should contain "* horticulture - basement mushrooms"
    And the stdout should contain "  horticulture - backyard bonsai"

  Scenario: Listing Projects by matching against arguments
    When I successfully run `tempo project -l "horticulture"`
    Then the stdout should not contain "sheep hearding"
    And the stdout should contain "* horticulture - basement mushrooms"
    And the stdout should contain "  horticulture - backyard bonsai"

  Scenario: Listing no Project when matching against arguments returns nothing
    When I successfully run `tempo project -l "beekeeping"`
    Then the stdout should contain "no projects match 'beekeeping'"

  Scenario: Adding a project
    When I successfully run `tempo project "hang gliding"`
    Then the stdout should contain "added project 'hang gliding'"

  Scenario: Adding a project without quotation marks
    When I successfully run `tempo project hang gliding`
    Then the stdout should contain "added project 'hang gliding'"

  Scenario: Attempting to add an exising project
    When I run `tempo checkout --add "horticulture - basement mushrooms"`
    Then the stdout should contain "error: project 'horticulture - basement mushrooms' already exists"

  Scenario: Deleting a project by exact match
    When I successfully run `tempo project -d "horticulture - backyard bonsai"`
    Then the stdout should contain "deleted project 'horticulture - backyard bonsai'"

  Scenario: Deleting a project by partial match
    When I successfully run `tempo project -d "backyard bonsai"`
    Then the stdout should contain "deleted project 'horticulture - backyard bonsai'"

  Scenario: Deleting a project without quotation marks
    When I successfully run `tempo project -d horticulture - backyard bonsai`
    Then the stdout should contain "deleted project 'horticulture - backyard bonsai'"

  Scenario: Deleting a project with list flag works even without quotes around a partial match
    When I successfully run `tempo project -d backyard bonsai -l`
    Then the stout should contain "* horticulture - basement mushrooms"
    And the stdout should contain "  sheep hearding"
    And the stdout should not contain "backyard bonsai"

  Scenario: Attempting to delete a non-existant project Fails
    When I run `tempo project -d "sheep hearding - lanolin extraction"`
    Then the stderr should contain "error: no such project 'sheep hearding - lanolin extraction'"

  Scenario: Attempting to Delete the current project Fails
    When I run `tempo project -d "horticulture - basement mushrooms"`
    Then the stdout should not contain "deleted project"
    And the stderr should contain "error: cannot delete the active project"