# frozen_string_literal: true
require 'test_helper'

class RepoAccessTest < ActiveSupport::TestCase
  setup do
    @student      = user(:student)
    @organization = organization(:classroom)

    @repo_access = RepoAccess.create(user: @student, organization: @organization)
  end

  teardown do
    RepoAccess.destroy_all
  end

  test '#create invites the user as a member of the organization' do
    url = github_url("/orgs/#{@organization.github_organization.login}/memberships/#{@student.github_user.login}")
    assert_requested :put, url
  end

  test '#create accepts the invitation to the organization on the students behalf' do
    url = github_url("/user/memberships/orgs/#{@organization.github_organization.login}")
    assert_requested :patch, url, headers: { 'Authorization' => "token #{@student.token}" }
  end

  test '#destroy removes the student from the organization' do
    @repo_access.destroy

    url = "/organizations/#{@organization.github_id}/members/#{@student.github_user.login}"
    assert_requested :delete, github_url(url), times: 2
  end

  test '#destroy does not remove the teacher from the organization' do
    teacher = user(:teacher)
    RepoAccess.create(user: user(:teacher), organization: @organization).destroy

    url = "/organizations/#{@organization.github_id}/members/#{teacher.github_user.login}"
    refute_requested :delete, url
  end
end
