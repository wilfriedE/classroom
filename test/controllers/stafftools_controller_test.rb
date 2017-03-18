# frozen_string_literal: true
require 'test_helper'

class StafftoolsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = user(:teacher) }

  test 'returns not found for GitHub Staff members' do
    sign_in_as(@user)

    assert_raise ActionController::RoutingError do
      get '/stafftools'
    end
  end

  test 'does not return not found for staff members' do
    @user.update_attributes(site_admin: true)
    sign_in_as(@user)

    get '/stafftools'
    assert_response :ok
  end
end
