# frozen_string_literal: true
require 'test_helper'

class NullGitHubRepositoryTest < ActiveSupport::TestCase
  setup do
    @null_github_repository = NullGitHubRepository.new
  end

  test '#full_name' do
    assert_equal 'Deleted repository', @null_github_repository.name
  end

  test '#html_url' do
    assert_equal '#', @null_github_repository.html_url
  end

  test '#name' do
    assert_equal 'Deleted repository', @null_github_repository.name
  end
end
