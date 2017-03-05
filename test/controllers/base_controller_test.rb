# frozen_string_literal: true
require 'test_helper'

class BaseController < ApplicationController
  def index
    head :ok
  end
end

class BaseControllerTest < ActionDispatch::IntegrationTest
  test 'redirects unauthenticated user to login path' do
    with_dummy_routes do
      get '/base'
      assert_redirected_to login_path
    end
  end

  test 'returns success if the user is authenticated' do
    with_dummy_routes do
      sign_in_as(user(:teacher))
      get '/base'

      assert_response :success
    end
  end

  private

  def with_dummy_routes
    Rails.application.routes.draw do
      get '/base' => 'base#index'
      get '/login', to: 'sessions#new', as: 'login'

      match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
      resources :organizations, path: 'classrooms'
    end

    yield

    Rails.application.routes_reloader.reload!
  end
end
