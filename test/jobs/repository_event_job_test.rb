# frozen_string_literal: true
require 'test_helper'

class RepositoryEventJobTest < ActiveJob::TestCase
  setup do
    @deleted_event = github_webhook_event('repository/deleted')
    @organization = organization(:classroom)
  end

  teardown { Group.destroy_all }

  test '#perform destroys the correspoing AssignmentRepo from GitHub' do
    assignment_repo = AssignmentRepo.create(
      assignment: assignment(:public_assignment),
      user: user(:student),
      github_repo_id: @deleted_event.dig(:repository, :id)
    )

    RepositoryEventJob.perform_now(@deleted_event)

    assert_raise ActiveRecord::RecordNotFound do
      assignment_repo.reload
    end
  end

  # TODO: Fixup this test so we don't have this many dependencies.
  # This is kind of ridiculous.
  test '#perform destroys the matching GroupAssignmentRepo from GitHub' do
    group_assignment = group_assignment(:public_group_assignment)
    group            = Group.create(title: 'Group 1', grouping: group_assignment.grouping)

    group_assignment_repo = GroupAssignmentRepo.create(group_assignment: group_assignment, group: group)
    @deleted_event[:repository][:id] = group_assignment_repo.github_repo_id

    RepositoryEventJob.perform_now(@deleted_event)

    assert_raise ActiveRecord::RecordNotFound do
      group_assignment_repo.reload
    end
  end
end
