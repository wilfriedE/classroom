# frozen_string_literal: true
require 'test_helper'

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organization(:classroom)
    @teacher      = user(:teacher)
  end

  test 'GET #index is successful' do
    sign_in_as(@teacher)
    get organizations_path(@organization)
    assert_response :success
  end

  test 'GET #new is successful' do
    sign_in_as(@teacher)
    get organizations_path(@organization)
    assert_response :success
  end

  test 'POST #create redirects the user to authenticate' do
  end
end
