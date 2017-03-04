# frozen_string_literal: true
require 'test_helper'

class NullGitHubUserTest < ActiveSupport::TestCase
  setup do
    @null_github_user = NullGitHubUser.new
  end

  test '#avatar_url returns the GitHub ghost user avatar' do
    assert_equal 'https://avatars.githubusercontent.com/u/10137?v=3', @null_github_user.avatar_url
  end

  test '#html_url returns the ghost GitHub user profile' do
    assert_equal 'https://github.com/ghost', @null_github_user.html_url
  end

  test '#id returns the ghost GitHub user id' do
    assert_equal 10_137, @null_github_user.id
  end

  test '#login returns the ghost user GitHub login' do
    assert_equal 'ghost', @null_github_user.login
  end

  test '#name' do
    assert_equal 'Deleted user', @null_github_user.name
  end
end
