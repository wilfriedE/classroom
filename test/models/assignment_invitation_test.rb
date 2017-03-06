# frozen_string_literal: true
require 'test_helper'

class AssignmentInvitationTest < ActiveSupport::TestCase
  setup do
    @assignment_invitation = assignment_invitation(:public_assignment_invitation)
    @assignment = @assignment_invitation.assignment
  end

  # This is needed until we remove ActiveRecord callbacks
  # from the #destroy action.
  teardown { AssignmentRepo.destroy_all }

  test '.default_scope hides deleted records' do
    @assignment_invitation.update_attributes(deleted_at: Time.zone.now)
    refute_includes AssignmentInvitation.all, @assignment_invitation
  end

  test '#redeem_for returns a AssignmentRepo::CreatorResult instance' do
    student = user(:student)
    result = @assignment_invitation.redeem_for(student)

    assert_instance_of AssignmentRepo::Creator::Result, result

    assert_predicate result, :success?
    assert_equal student, result.assignment_repo.user
  end

  test '#title is delegated to the assignment' do
    assert_equal @assignment.title, @assignment_invitation.title
  end

  test '#to_param returns the key' do
    assert_equal @assignment_invitation.key, @assignment_invitation.to_param
  end
end
