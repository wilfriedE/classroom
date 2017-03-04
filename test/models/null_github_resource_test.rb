# frozen_string_literal: true
require 'test_helper'

class NullGitHubResourceTest < ActiveSupport::TestCase
  setup do
    @null_github_resource = NullGitHubResource.new
  end

  test '#null? returns true' do
    assert @null_github_resource.null?
  end
end
