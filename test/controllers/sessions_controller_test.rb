# frozen_string_literal: true
require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @teacher = user(:teacher)
  end

  test 'GET #new redirects to GitHub with the default scopes' do
    scope_param = { scope: 'user:email,repo,delete_repo,admin:org,admin:org_hook' }.to_param

    get login_path
    assert_redirected_to "/auth/github?#{scope_param}"
  end

  test 'POST #create finds an existing user from the OmniAuth hash' do
    omniauth_for(@teacher)

    assert_difference('User.count', 0) do
      post '/auth/github/callback'
    end
  end

  test 'POST #create creates a new user from the Omniauth hash' do
    omniauth_for(@teacher)
    @teacher.destroy

    assert_difference('User.count', 1) do
      post '/auth/github/callback'
    end
  end

  test 'POST #create sets the approriate session keys and redirects' do
    sign_in_as(@teacher)

    assert_equal session[:user_id], @teacher.id
    assert_equal session[:current_scopes], @teacher.github_client_scopes

    assert_redirected_to organizations_path
  end

  test 'DELETE #destroy resets the session and redirects to the root path' do
    post logout_path

    refute session.key?(:user_id)
    refute session.key?(:current_scopes)
    assert_redirected_to root_path
  end

  test 'GET #failure redirects to the root path with a flash message' do
    get '/auth/failure'

    assert_equal 'There was a problem authenticating with GitHub, please try again.', flash[:alert]
    assert_redirected_to root_path
  end

  private

  # rubocop:disable AbcSize
  def omniauth_for(user)
    OmniAuth.config.mock_auth[:github].uid = user.uid
    OmniAuth.config.mock_auth[:github].extra.raw_info.site_admin = user.site_admin
    OmniAuth.config.mock_auth[:github].credentials.token = user.token
  end
  # rubocop:enable AbcSize
end
