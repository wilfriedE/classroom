# frozen_string_literal: true
require 'test_helper'

class NullGitHubTeamTest < ActiveSupport::TestCase
  setup do
    @null_github_team = NullGitHubTeam.new
  end

  test '#name' do
    assert_equal 'Deleted team', @null_github_team.name
  end

  test '#organization returns a NullGitHubOrganization' do
    assert_kind_of NullGitHubOrganization, @null_github_team.organization
  end

  test '#slug' do
    assert_equal 'ghost', @null_github_team.slug
  end
end
