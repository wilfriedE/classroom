# frozen_string_literal: true
class NullGitHubOrganization < NullGitHubUser
  def name
    'Deleted organization'
  end
end
