Feature: User Login

  Scenario: When user logs in with correct password, then they are navigated to the url
    Given I am a user with email address 'admin@example.com' and password 'password'
    When I am taken to the login page in order to access '/pages'
    And I fill in my email with 'admin@example.com'
    And I fill in my password with 'password'
    And I click login
    Then I am taken to '/pages'

  Scenario: When user logs in with incorrect password, then they are redirected back to the login page
    Given I am a user with email address 'admin@example.com' and password 'password'
    When I am taken to the login page in order to access '/pages'
    And I fill in my email with 'admin@example.com'
    And I fill in my password with 'incorrect'
    And I click login
    Then I am taken to '/login'
    But when I successfully log in I will be taken to '/pages'