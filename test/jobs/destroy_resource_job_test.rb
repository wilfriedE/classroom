# frozen_string_literal: true
require 'test_helper'

class DestroyResourceJobTest < ActiveJob::TestCase
  setup do
    @organization = organization(:classroom)
  end

  test '#perform uses the trash_can queue' do
    assert_performed_with(job: DestroyResourceJob, args: [@organization], queue: 'trash_can') do
      DestroyResourceJob.perform_later(@organization)
    end
  end

  test '#perform destroys the resource' do
    DestroyResourceJob.perform_now(@organization)

    assert_raises ActiveRecord::RecordNotFound do
      @organization.reload
    end
  end
end
