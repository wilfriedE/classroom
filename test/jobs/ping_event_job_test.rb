# frozen_string_literal: true
require 'test_helper'

class PingEventJobTest < ActiveJob::TestCase
  setup do
    @organization = organization(:classroom)
    @payload = github_webhook_event('ping')
  end

  test '#perform updates organization to show the webhook is active' do
    @organization.update_attributes(
      github_id: @payload.dig(:organization, :id),
      webhook_id: @payload[:hook_id]
    )

    PingEventJob.perform_now(@payload)
    @organization.reload

    assert_predicate @organization, :is_webhook_active?
  end

  test '#perform does not update an organization it does not match' do
    PingEventJob.perform_now(@payload)
    @organization.reload

    refute_predicate @organization, :is_webhook_active?
  end
end
