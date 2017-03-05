# frozen_string_literal: true
require 'test_helper'

class GitHubTeamTest < ActiveSupport::TestCase
  setup do
    Octokit.reset!
    @github_organization = organization(:classroom).github_organization
    @github_team         = @github_organization.create_team('test-team')
  end

  teardown do
    @github_organization.delete_repository(@repository.id) if @repository.present?
    @github_organization.delete_team(@github_team.id)
  end

  test 'responds to all of the GitHub attributes with the proper GitHub information' do
    gh_team = oauth_client.team(@github_team.id)

    @github_team.attributes.each do |attribute, value|
      next if attribute == :client || attribute == :access_token || attribute == :organization
      assert_respond_to @github_team, attribute

      if value.nil?
        assert_nil value, gh_team.send(attribute)
      else
        assert_equal value, gh_team.send(attribute)
      end
    end

    assert_requested :get, github_url("/teams/#{@github_team.id}"), times: 2
  end

  test 'responds to all *_no_cache methods' do
    @github_team.attributes.each do |attribute, _|
      next if attribute == :id || attribute == :client || attribute == :access_token
      assert_respond_to @github_team, "#{attribute}_no_cache"
    end
  end

  test '#add_team_membership adds a user to a GitHub team' do
  end

  test '#remove_team_membership removes a user from a GitHub team' do
  end

  test '#add_team_repository adds a repository to a GitHub team with push permission' do
    @repository = @github_organization.create_repository('test-for-teams')
    url         = "/teams/#{@github_team.id}/repos/#{@repository.full_name}"

    body = {
      permission: 'push',
      name: {
        owner: @github_organization.login,
        name: 'test-for-teams'
      }
    }.to_json

    @github_team.add_team_repository(@repository.full_name)
    assert_requested :put, github_url(url), body: body
  end

  test '#add_team_repository adds a repository to a GitHub team with a given permission' do
    @repository = @github_organization.create_repository('test-for-teams')
    url         = "/teams/#{@github_team.id}/repos/#{@repository.full_name}"

    body = {
      permission: 'admin',
      name: {
        owner: @github_organization.login,
        name: 'test-for-teams'
      }
    }.to_json

    @github_team.add_team_repository(@repository.full_name, permission: 'admin')
    assert_requested :put, github_url(url), body: body
  end

  test '#team_repository? verifies if the repository belongs to the team' do
    @github_team.team_repository?('rails/rails')
    assert_requested :get, github_url("/teams/#{@github_team.id}/repos/rails/rails")
  end

  test '#html_url' do
    url = "https://github.com/orgs/#{@github_team.github_organization.login}/teams/#{@github_team.slug}"
    assert_equal url, @github_team.html_url
  end

  test '#github_organization returns the correct GitHubOrganization instance' do
    github_organization = @github_team.github_organization
    assert_kind_of GitHubOrganization, github_organization
    assert_equal @github_team.organization.id, github_organization.id
  end
end
