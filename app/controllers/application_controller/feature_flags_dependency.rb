# frozen_string_literal: true
class ApplicationController
  def ensure_team_management_flipper_is_enabled
    not_found unless team_management_enabled?
  end

  def ensure_student_identifier_flipper_is_enabled
    not_found unless student_identifier_enabled?
  end

  def student_identifier_enabled?
    return false unless logged_in?
    GitHubClassroom.flipper[:student_identifier].enabled?(current_user)
  end
  helper_method :student_identifier_enabled?

  def team_management_enabled?
    return false unless logged_in?
    GitHubClassroom.flipper[:team_management].enabled?(current_user)
  end
  helper_method :team_management_enabled?
end
