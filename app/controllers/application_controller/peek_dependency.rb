# frozen_string_literal: true
class ApplicationController
  def peek_enabled?
    return false unless logged_in?
    current_user.staff?
  end
end
