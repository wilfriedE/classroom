# frozen_string_literal: true

class Deadline < ApplicationRecord
  belongs_to :assignment, polymorphic: true
  validates :deadline_at, presence: true
  validate :deadline_in_future

  after_create :create_job

  def create_job
    DeadlineJob.set(wait_until: deadline_at).perform_later(id)
  end

  def passed?
    deadline_at.past?
  end

  # Accepts an optional datetime format string :datetime_format
  # Default DateTime format is %m/%d/%Y %H:%M %z
  # e.g. 05/25/2017 13:17-0800
  def self.build_from_string(opts = {})
    deadline = Deadline.new

    format = opts[:datetime_format] || '%m/%d/%Y %H:%M %z'
    deadline.deadline_at = DateTime.strptime(opts[:deadline_at], format) if opts[:deadline_at]

    deadline
  rescue ArgumentError
    deadline.errors.add(:deadline_at, 'not formatted correctly.') && deadline
  end

  private

  def deadline_in_future
    errors.add(:base, 'Deadline must be in the future') if deadline_at && deadline_at < Time.zone.now
  end
end
