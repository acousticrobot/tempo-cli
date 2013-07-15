Feature: GLI bootstrapping sets up cucumber
  GLI scaffold includes aruba and cucumber setup

  Scenario: App just runs
    When I get help for "tempo"
    Then the exit status should be 0
