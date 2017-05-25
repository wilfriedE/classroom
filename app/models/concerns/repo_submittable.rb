# frozen_string_literal: true

module RepoSubmittable
  extend ActiveSupport::Concern

  def submission_failed?
    submission_passed? && submission_sha.blank?
  end

  def submission_succeeded?
    submission_passed? && submission_sha.present?
  end

  def submission_passed?
    assignment.deadline&.passed?
  end

  def submission_url
    return unless submission_succeeded?

    github_repository.tree_url_for_sha(submission_sha)
  end
end
