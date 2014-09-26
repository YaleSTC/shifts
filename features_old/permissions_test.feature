Feature: Permissions test
    In order to manage permissions
    As a superuser admin
    I want to be able to create and manage permissions

  Scenario: creating a permission
#  Given I am a superuser admin
  And I am on the list of permissions
  When I follow "Add Permission"
  And I fill in "Name" with "Free Willy"
  And I fill in "Info" with "the ability to go free"
  And I follow "Update Permission"
  Then I should see "Permission was successfully updated"
  And I should see "Free Willy"
  And I should see "the ability to go free"
  And I should have 1 permission

  Scenario: Editing a permission
#  Given I am a superuser admin
  And I am on the list of permissions
#  And there is a permission called "Extraneous" with "the ability to be superfluous"
  When I follow "Edit"
  And I fill in "Name" with "Charlie"
  And I fill in "Info" with "and the Chocolate Factory"
  And I follow "Update Permission"
  Then I should see "Permission was successfully updated"
  And I should see "Charlie"
  And I should see "and the Chocolate Factory"
  And I should have 1 permission

  Scenario: Deleting a permission
#  Given I am a superuser admin
  And I am on the list of permissions
#  And there is a permission called "Extraneous" with "the ability to be superfluous"
  When I follow "Delete"
  And I follow "ok"
  Then I should see "Permission was successfully deleted"
  And I should have 0 permissions

