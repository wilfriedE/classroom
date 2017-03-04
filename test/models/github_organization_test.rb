# frozen_string_literal: true
require 'test_helper'

class GitHubOrganizationTest < ActiveSupport::TestCase
  setup do
    Octokit.reset!
    @repo_name = 'test-repository'
    @organization = organization(:classroom)
    @github_organization = @organization.github_organization
  end

  test 'responds to all of the GitHub attributes with the proper GitHub information' do
    gh_organization = oauth_client.organization(@organization.github_id)

    @github_organization.attributes.each do |attribute, value|
      next if attribute == :id || attribute == :client || attribute == :access_token
      assert_respond_to @github_organization, attribute

      if value.nil?
        assert_nil value, gh_organization.send(attribute)
      else
        assert_equal value, gh_organization.send(attribute)
      end
    end

    assert_requested :get, github_url("/organizations/#{@organization.github_id}"), times: 2
  end

  test 'responds to all *_no_cache methods' do
    @github_organization.attributes.each do |attribute, _|
      next if attribute == :id || attribute == :client || attribute == :access_token
      assert_respond_to @github_organization, "#{attribute}_no_cache"
    end
  end

  test '#accept_membership' do
  end

  test '#add_membership' do
  end

  test '#admin?' do
    teacher = user(:teacher)
    assert @github_organization.admin?(teacher.github_user.login)

    student = user(:student)
    refute @github_organization.admin?(student.github_user.login)
  end

  test '#create_repository -> #delete_repository' do
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

  test '#plan' do
  end

  test '#remove_organization_member removes the user from the organization' do
    student = user(:student)
    url     = "/organizations/#{@organization.github_id}/members/#{student.github_user.login}"

    stub_github_delete(url)
    @github_organization.remove_organization_member(student.github_user.login)

    assert_requested :delete, github_url(url)
  end

  test '#remove_organization_member does not remove an admin from the organization' do
    teacher = user(:teacher)
    url     = "/organizations/#{@organization.github_id}/members/#{teacher.github_user.login}"

    stub_github_delete(url)
    @github_organization.remove_organization_member(teacher.github_user.login)

    refute_requested :delete, github_url(url)
  end

  test '#team_invitations_url' do
    url = "https://github.com/orgs/#{@github_organization.login}/people"
    assert_equal url, @github_organization.team_invitations_url
  end

  test '#create_organization_webhook' do
    url = "/organizations/#{@github_organization.id}/hooks"
    body = {
      name: 'web',
      config: {
        content_type: 'json',
        secret: '453977a8e36e4f511251c70be990f920d77c118298a39e614ac6adbac33740a2054a48c8694a957d3b92ce9734fe7e1131417e2729831d12d36563a42fe46e5d' # rubocop:disable LineLength
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
  end
end
