# frozen_string_literal: true
class ApplicationController
  before_action :authenticate_user!

  def authenticate_user!
    return auth_redirect unless logged_in? && adequate_scopes?
    LastActiveJob.perform_later(current_user.id, Time.zone.now.to_i)
  end

  def adequate_scopes?
    required_scopes.all? { |scope| current_scopes.include?(scope) }
  end

  def auth_redirect
    session[:pre_login_destination] = "#{request.base_url}#{request.path}"
    session[:required_scopes] = required_scopes.join(',')
    redirect_to login_path
  end

  def current_scopes
    return [] unless logged_in?
    session[:current_scopes] ||= current_user.github_client_scopes
  end

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = if true_user.try(:staff?) && session[:impersonated_user_id]
                      User.find_by(id: session[:impersonated_user_id])
                    else
                      true_user
                    end
  end
  helper_method :current_user

  def logged_in?
    !current_user.nil?
  end
  helper_method :logged_in?

  def required_scopes
    GitHubClassroom::Scopes::TEACHER
  end

  def true_user
    @true_user ||= User.find_by(id: session[:user_id])
  end
  helper_method :true_user
end
