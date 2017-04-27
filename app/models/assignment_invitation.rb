# frozen_string_literal: true

class AssignmentInvitation < ApplicationRecord
  default_scope { where(deleted_at: nil) }

  update_index('stafftools#assignment_invitation') { self }

  has_one :organization, through: :assignment

  belongs_to :assignment

  validates :assignment, presence: true

  validates :key, presence:   true
  validates :key, uniqueness: true

  after_initialize :assign_key

  delegate :title, to: :assignment

  # Public: Redeem an AssignmentInvtiation for a User invitee.
  #
  # Returns a AssignmentInvitation::Redeemer::Result.
  def redeem_for(invitee)
    AssignmentInvitation::Redeemer.perform(invitation: self, invitee: invitee)
  end

  def to_param
    key
  end

  protected

  def assign_key
    self.key ||= SecureRandom.hex(16)
  end
end
