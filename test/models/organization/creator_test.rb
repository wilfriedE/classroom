# frozen_string_literal: true
require 'test_helper'

class Organization::CreatorTest < ActiveSupport::TestCase
  setup do
    @organization_attributes = organization(:classroom).attributes
    @teacher = user(:teacher)

    Organization.destroy_all
  end

  teardown do
    @organization.try(:destroy)
  end

  test '::perform successfully creates an Organization with a webhook_id' do
    result = Organization::Creator.perform(github_id: @organization_attributes['github_id'], users: [@teacher])

    assert_predicate result, :success?
    assert_kind_of Organization, result.organization
    assert_equal @organization_attributes['github_id'], result.organization.github_id
    assert_predicate result.organization.webhook_id, :present?
  end

  # test '::perform does not allow non admins to add an organization' do
  # end
  #
  # test '::perform deletes the webhook is the creation fails' do
  #
  # end
  #
  # test '::perform deletes the Organization if the repository permissions cannot be set to none' do
  #
  # end
end
