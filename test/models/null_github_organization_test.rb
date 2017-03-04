# frozen_string_literal: true
require 'test_helper'

class NullGitHubOrganizationTest < ActiveSupport::TestCase
  setup do
    @null_github_organization = NullGitHubOrganization.new
  end

  test '#inherits from NullGitHubUser' do
    assert_kind_of NullGitHubUser, @null_github_organization
  end

  test '#name' do
    assert_equal 'Deleted organization', @null_github_organization.name
  end
end
