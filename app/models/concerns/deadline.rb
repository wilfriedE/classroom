# frozen_string_literal: true

module Deadline
  extend ActiveSupport::Concern

  included do
    after_create do
      set_deadline_job if has_deadline?
    end
  end

  def set_deadline_job
    Rails.logger.info "Setting deadline job"
    DeadlineJob.set(wait_until: deadline).perform_later(self)
  end

  def has_deadline?
    deadline.present?
  end
end
