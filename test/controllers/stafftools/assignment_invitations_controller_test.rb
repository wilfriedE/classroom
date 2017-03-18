# frozen_string_literal: true
require 'test_helper'

class Stafftools::AssignmentInvitationsControllerTest < ActionDispatch::IntegrationTest
  setup { @githubber = users(:teacher).update_attributes(site_admin: true) }
end
