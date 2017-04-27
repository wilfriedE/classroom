# frozen_string_literal: true

class AssignmentInvitation
  class Redeemer
    attr_reader :assignment, :invitee

    def self.perform(invitation:, invitee:)
      new(invitation: invitation, invitee: invitee)
    end

    def initialize(invitation:, invitee:)
      @assignment = invitation.assignment
      @invitee    = invitee
    end

    def perform
      # options = { assignment: assignment }
      #
      # options.tap do |opts|
      #   if (repo_access = RepoAccess.find_by(user: invitee, organization: organization))
      #     opts[:repo_access] = repo_access
      #   else
      #     opts[:user] = invitee
      #   end
      # end
      #
      # if (submission = AssignmentRepo.find_by(options))
      #   next unless present_on_github?(submission)
      #   return AssignmentRepo::Creator::Result.success(submission)
      # end
      #
      # AssignmentRepo::Creator.perform(assignment: assignment, user: invitee)
    end
  end
end
