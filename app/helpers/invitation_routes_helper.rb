# frozen_string_literal: true

module InvitationRoutesHelper
  def successful_invitation_path(context)
    if context.is_a?(GroupAssignment)
      successful_invitation_group_assignment_invitation_path
    else
      successful_invitation_assignment_invitation_path
    end
  end
end
