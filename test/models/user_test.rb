# frozen_string_literal: true
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @github_omniauth_hash = OmniAuth.config.mock_auth[:github]
    @user = user(:teacher)
  end

  test 'last_active_at must be present' do
    @user.last_active_at = nil
    refute_valid @user
  end

  test 'token must be present' do
    @user.token = nil
    refute_valid @user
  end

  test 'token must be unique' do
    @user.token = user(:student).token
    refute_valid @user
  end

  test 'uid must be present' do
    @user.uid = nil
    refute_valid @user
  end

  test 'uid must be unique' do
    @user.uid = user(:student).uid
    refute_valid @user
  end

  test '#assign_from_auth_hash properly updates a users attributes' do
    @user.assign_from_auth_hash(@github_omniauth_hash)

    assert_valid @user

    assert_equal @github_omniauth_hash.uid,                       @user.uid
    assert_equal @github_omniauth_hash.extra.raw_info.site_admin, @user.site_admin
    refute_equal @github_omniauth_hash.credentials.token,         @user.token
  end

  test 'does not allow the deprecation of token scope on update' do
    good_token = @user.token
    @user.update_attributes(token: SecureRandom.hex(20))

    assert_equal good_token, @user.token
  end

  test '#authorized_access_token returns if the token is authorized on GitHub' do
    assert_predicate @user, :authorized_access_token?
  end

  test '#find_by_auth_hash returns the proper user' do
    @github_omniauth_hash.uid = @user.uid

    found_user = User.find_by_auth_hash(@github_omniauth_hash)
    assert_equal @user, found_user
  end

  test '#flipper_id should include the users id' do
    assert_equal "User:#{@user.id}", @user.flipper_id
  end

  test '#github_client_scopes returns an Array of OAuth token scopes' do
    scopes = @user.github_client_scopes

    %w(admin:org admin:org_hook delete_repo repo user:email).each do |scopet|
      assert_includes scopes, scopet
    end
  end

  test '#github_client returns an Octokit::Client with the users token' do
    assert_kind_of Octokit::Client, @user.github_client
    assert_equal @user.github_client.access_token, @user.token
  end

  test "#github_user returns the User's presence on GitHub" do
    assert_kind_of GitHubUser, @user.github_user
    assert_equal @user.github_user.id, @user.uid
  end

  test '#staff? responds with site_admin attribute' do
    refute_predicate @user, :site_admin
    refute_predicate @user, :staff?

    @user.update_attributes(site_admin: true)

    assert_predicate @user, :site_admin
    assert_predicate @user, :staff?
  end
end
