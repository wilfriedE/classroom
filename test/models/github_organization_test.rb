# frozen_string_literal: true
require 'test_helper'

class GitHubOrganizationTest < ActiveSupport::TestCase
  setup do
    Octokit.reset!
    @repo_name           = 'test-repository'
    @github_organization = organization(:classroom).github_organization
  end

  test 'responds to all of the GitHub attributes with the proper GitHub information' do
    gh_organization = oauth_client.organization(@github_organization.id)

    @github_organization.attributes.each do |attribute, value|
      next if attribute == :id || attribute == :client || attribute == :access_token
      assert_respond_to @github_organization, attribute

      if value.nil?
        assert_nil value, gh_organization.send(attribute)
      else
        assert_equal value, gh_organization.send(attribute)
      end
    end

    assert_requested :get, github_url("/organizations/#{@github_organization.id}"), times: 2
  end

  test 'responds to all *_no_cache methods' do
    @github_organization.attributes.each do |attribute, _|
      next if attribute == :id || attribute == :client || attribute == :access_token
      assert_respond_to @github_organization, "#{attribute}_no_cache"
    end
  end

  test '#add_membership creates a pending membership for a user' do
    student         = user(:student)
    memberships_url = "/orgs/#{@github_organization.login}/memberships/#{student.github_user.login}"

    stub_github_put(memberships_url)
    @github_organization.add_membership(student.github_user.login)

    assert_requested :put, github_url(memberships_url)
  end

  test '#add_membership will not add an existing organization member' do
    teacher         = user(:teacher)
    memberships_url = "/organizations/#{@github_organization.login}/memberships/#{teacher.github_user.login}"

    @github_organization.add_membership(teacher.github_user.login)

    refute_requested :put, github_url(memberships_url)
  end

  test '#admin?' do
    membership_url = "/orgs/#{@github_organization.login}/memberships"

    teacher = user(:teacher)
    assert @github_organization.admin?(teacher.github_user.login)
    assert_requested :get, github_url("#{membership_url}/#{teacher.github_user.login}")

    student = user(:student)
    refute @github_organization.admin?(student.github_user.login)
    assert_requested :get, github_url("#{membership_url}/#{student.github_user.login}")
  end

  test '#create_repository -> #delete_repository' do
    assignment_name = 'new-assignment'

    body = {
      has_issues:    true,
      has_wiki:      true,
      has_downloads: true,
      name:          assignment_name
    }.to_json

    repository = @github_organization.create_repository(assignment_name)
    assert_requested :post, github_url("/organizations/#{@github_organization.id}/repos"), body: body

    @github_organization.delete_repository(repository.id)
    assert_requested :delete, github_url("/repositories/#{repository.id}")
  end

  test '#create_team -> #delete_team' do
    url = "/organizations/#{@github_organization.id}/teams"

    team = @github_organization.create_team('the-a-team')
    assert_requested :post, github_url(url)

    @github_organization.delete_team(team.id)
    assert_requested :delete, github_url("/teams/#{team.id}")
  end

  test '#geo_pattern_data_uri returns a uri from the organization github id' do
    uri = GeoPattern.generate(@github_organization.id, color: '#5fb27b').to_data_uri
    assert_equal uri, @github_organization.geo_pattern_data_uri
  end

  test '#github_avatar_url has a default size of 40' do
    assert_equal "#{@github_organization.avatar_url}&size=40", @github_organization.github_avatar_url
  end

  test '#github_avatar_url can have a custom size' do
    assert_equal "#{@github_organization.avatar_url}&size=60", @github_organization.github_avatar_url(60)
  end

  test '#organization_members returns an Array of members' do
    assert_kind_of Array, @github_organization.organization_members
  end

  test '#organization_member? returns true if user is a member of the GitHub organization' do
    teacher = user(:teacher)
    assert @github_organization.organization_member?(teacher.github_user.login)
  end

  test '#organization_member? returns false if user is a not member of the GitHub organization' do
    student = user(:student)
    refute @github_organization.organization_member?(student.github_user.login)
  end

  test '#plan returns the number of owned private repos and the number available' do
    assert plan = @github_organization.plan
    assert_kind_of Hash, plan

    assert plan.key?(:owned_private_repos)
    assert plan.key?(:private_repos)
  end

  test '#remove_organization_member removes the user from the organization' do
    student = user(:student)
    url     = "/organizations/#{@github_organization.id}/members/#{student.github_user.login}"

    stub_github_delete(url)
    @github_organization.remove_organization_member(student.github_user.login)

    assert_requested :delete, github_url(url)
  end

  test '#remove_organization_member does not remove an admin from the organization' do
    teacher = user(:teacher)
    url     = "/organizations/#{@github_organization.id}/members/#{teacher.github_user.login}"

    stub_github_delete(url)
    @github_organization.remove_organization_member(teacher.github_user.login)

    refute_requested :delete, github_url(url)
  end

  test '#team_invitations_url' do
    url = "https://github.com/orgs/#{@github_organization.login}/people"
    assert_equal url, @github_organization.team_invitations_url
  end

  test '#create_organization_webhook creates an active webhook that catches all events' do
    url = "/organizations/#{@github_organization.id}/hooks"
    body = {
      name: 'web',
      config: {
        content_type: 'json',
        secret: Rails.application.secrets.webhook_secret
      },
      events: ['*'],
      active: true
    }.to_json

    stub_github_post(url)
    @github_organization.create_organization_webhook

    assert_requested :post, github_url(url), body: body
  end

  test '#remove_organization_webhook' do
    webhook_id = 1
    url = "/organizations/#{@github_organization.id}/hooks/#{webhook_id}"

    stub_github_post(url)
    @github_organization.remove_organization_webhook(webhook_id)

    assert_requested :delete, github_url(url)
  end

  test '#update_default_repository_permission!' do
    url = "/organizations/#{@github_organization.id}"
    body = { default_repository_permission: 'read' }.to_json

    stub_github_patch(url)
    @github_organization.update_default_repository_permission!('read')

    assert_requested :patch, github_url(url), body: body
  end
end
