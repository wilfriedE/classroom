# frozen_string_literal: true
require 'test_helper'

class LastActiveJobTest < ActiveJob::TestCase
  setup do
    Timecop.freeze(Time.zone.now)

    @time = (Time.zone.now + 600).to_i
    @user = user(:teacher)
  end

  teardown do
    Timecop.return
  end

  test 'use the :last_active_at queue' do
    assert_performed_with(job: LastActiveJob, args: [@user.id, @time], queue: 'last_active') do
      LastActiveJob.perform_later(@user.id, @time)
    end
  end

  test 'update the last_active_at attribute for a User' do
    LastActiveJob.perform_now(@user.id, @time)
    @user.reload
    assert_equal Time.zone.at(@time), @user.last_active_at
  end

  test 'do not change the updated_at column' do
    LastActiveJob.perform_now(@user.id, @time)
    @user.reload
    refute_equal @user.updated_at, @user.last_active_at
  end

  test 'do not raise an error if the User is not longer present' do
    @user_id = @user.id
    @user.destroy
    LastActiveJob.perform_now(@user_id, @time)
  end
end
