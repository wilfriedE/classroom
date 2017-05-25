class DeadlineJob < ApplicationJob
  queue_as :deadline

  def perform(assignment)
    Rails.logger.error "Deadline reached for assignment ID: #{assignment.id}"
  end
end
