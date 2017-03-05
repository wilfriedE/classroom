# frozen_string_literal: true
require 'test_helper'

class GitHubUserTest < ActiveSupport::TestCase
  setup do
    Octokit.reset!
    @teacher = user(:teacher).github_user
    @student = user(:student).github_user
  end

  test 'responds to all of the GitHub attributes with the proper GitHub information' do
    gh_teacher = oauth_client.user(@teacher.id)

    @teacher.attributes.each do |attribute, value|
      next if attribute == :client || attribute == :access_token
      assert_respond_to @teacher, attribute
      assert_equal value, gh_teacher.send(attribute)
    end

    assert_requested :get, github_url("/user/#{@teacher.id}"), times: 2
  end

  test 'responds to all *_no_cache methods' do
    @teacher.attributes.each do |attribute, _|
      next if attribute == :id || attribute == :client || attribute == :access_token
      assert_respond_to @teacher, "#{attribute}_no_cache"
    end
  end

  test '#accept_membership_to accepts a membership for a non member' do
    organization    = organization(:classroom).github_organization
    memberships_url = "/user/memberships/orgs/#{organization.login}"

    stub_github_patch(memberships_url)
    @student.accept_membership_to(organization)

    assert_requested :patch, github_url(memberships_url), \
                     headers: { 'Authorization' => "token #{@student.access_token}" }
  end

  test '#accept_membership_to does not accept a membership for an existing member' do
    organization    = organization(:classroom).github_organization
    memberships_url = "/user/memberships/#{organization.login}"

    @teacher.accept_membership_to(organization)
    refute_requested :patch, memberships_url
  end

  test '#accept_repository_invitation' do
    invitation_id = 1
    stub_github_patch("/user/repository_invitations/#{invitation_id}")

    @student.accept_repository_invitation(invitation_id)
    assert_requested :patch, github_url("/user/repository_invitations/#{invitation_id}")
  end

  test '#authorized_access_token? returns true when the user has a valid GitHub token' do
    assert @teacher.authorized_access_token?
  end

  test '#authorized_access_token? returns false when the user does not have a valid GitHub token' do
    token = '8d973c7f33e36412cd3b10272b8e8736b759300'
    user  = User.create(id: 42, uid: 42, token: token)

    refute user.authorized_access_token?
  end

  test '#github_avatar_url has a default size of 40' do
    assert_equal "#{@teacher.avatar_url}&size=40", @teacher.github_avatar_url
  end

  test '#github_avatar_url can have a custom size' do
    assert_equal "#{@teacher.avatar_url}&size=60", @teacher.github_avatar_url(60)
  end

  test '#organization_memberships returns an Array of memberships' do
    assert_kind_of Array, @teacher.organization_memberships
  end

  test '#organization_member? checks the membership status and returns a boolean' do
    organization = organization(:classroom).github_organization
    assert @teacher.organization_member?(organization)
  end
end
