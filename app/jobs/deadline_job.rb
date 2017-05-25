class DeadlineJob < ApplicationJob
  queue_as :deadline

  def perform(assignment)
    assignment.assignment_repos.each do |repo|
      protect_master_branch(repo)
    end
  end

  def protect_master_branch(repo)
    repo.github_repository.protect_branch('master', enforce_admins: true)
  end
end
