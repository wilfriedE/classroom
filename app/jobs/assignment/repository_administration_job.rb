# frozen_string_literal: true
module Assignment
  class RepositoryAdministrationJob < ApplicationJob
    queue :assignment

    def perform(assignment, time:, change:)
      time = Time.at(time).to_date_time
      assignment.assignment_repos.each do |assignment_repo|

      end
    end
  end
end
