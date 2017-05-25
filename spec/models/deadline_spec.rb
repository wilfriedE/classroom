# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssignmentInvitation, type: :model do
  describe '#create_job' do
    it 'enqueues job with correct parameters at correct time' do
      ActiveJob::Base.queue_adapter = :test
      tomorrow_time = Time.zone.now + 1.day

      expect { Deadline.create(deadline_at: tomorrow_time) }
        .to have_enqueued_job(DeadlineJob)
        .at(tomorrow_time)
    end
  end
end
