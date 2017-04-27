# frozen_string_literal: true

class AssignmentInvitationsController < ApplicationController
  include InvitationsControllerMethods
  include InvitationRoutesHelper

  def accept
    result = current_invitation.redeem_for(current_user)

    if result.success?
      redirect_to successful_invitation_path(current_invitation)
    else
      flash[:error] = result.error
      redirect_to assignment_invitation_path(invitation)
    end
  end

  private

  def current_invitation
    @current_invitation ||= AssignmentInvitation.find_by!(key: params[:id])
  end

  def current_repository_submission
    return @current_repository_submission if defined?(@current_repository_submission)
    assignment_repo = AssignmentRepo.find_by(
      assignment_id: current_assignment.id,
      user_id: current_user.id
    )

    @current_repository_submission = assignment_repo if assignment_repo.present?
  end

  def required_scopes
    GitHubClassroom::Scopes::ASSIGNMENT_STUDENT
  end
end
