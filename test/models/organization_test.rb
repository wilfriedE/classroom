# frozen_string_literal: true
require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  setup do
    @organization = organization(:classroom)
  end

  test '.default_scope hides deleted records' do
    @organization.update_attributes(deleted_at: Time.zone.now)
    refute_includes Organization.all, @organization
  end

  test 'title must be present' do
    @organization.title = nil
    refute @organization.valid?
    assert @organization.errors.include?(:title)
  end

  test 'title cannot be longer than 60 characters' do
    @organization.title = 'aa' * 60
    refute @organization.valid?
    assert @organization.errors.include?(:title)
  end

  test 'github_id must be present' do
    @organization.github_id = nil
    refute @organization.valid?
    assert @organization.errors.include?(:github_id)
  end

  test 'github_id must be unique' do
    other_organization = Organization.create(
      github_id: @organization.github_id,
      title: 'Classroom for geniuses'
    )

    refute other_organization.valid?
  end

  test '#all_assignments returns an Array of Assignments and GroupAssignments' do
    assert all_assignments = @organization.all_assignments
    assert_kind_of Array, all_assignments

    @organization.assignments.each do |assignment|
      assert_includes all_assignments, assignment
    end

    @organization.group_assignments.each do |group_assignment|
      assert_includes all_assignments, group_assignment
    end
  end

  test '#flipper_id should include the organizations id' do
    assert_equal "Organization:#{@organization.id}", @organization.flipper_id
  end

  test '#github_client returns an Octokit::Client with an access token' do
    assert_kind_of Octokit::Client, @organization.github_client
    assert @organization.github_client.access_token.present?
  end

  test '#github_organization returns the Organizations presence on GitHub' do
    assert_kind_of GitHubOrganization, @organization.github_organization
    assert_equal @organization.github_organization.id, @organization.github_id
  end

  test 'destroys the GitHub organization webhook on #destroy' do
    @organization.update_attributes(webhook_id: 9_999_999, is_webhook_active: true)
    @organization.destroy

    assert_requested :delete, github_url("/organizations/#{@organization.github_id}/hooks/#{@organization.webhook_id}")
  end
end
