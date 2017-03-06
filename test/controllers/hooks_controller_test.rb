# frozen_string_literal: true
require 'test_helper'

class HooksControllerTest < ActionDispatch::IntegrationTest
  test 'POST #receive responds with a 404 if the User-Agent is not correct' do
    assert_raise ActionController::RoutingError do
      send_webhook(payload: { foo: 'bar' }, headers: { 'User-Agent' => 'GitLab-Heckshoot/12345' })
    end
  end

  test 'POST #receive responds with a 400 when the payload is missing' do
    send_webhook(payload: nil)
    assert_response 400
  end

  test 'POST #receive responds with :forbidden if the signatures do not match' do
    send_webhook(payload: { foo: 'bar' }, headers: { 'HTTP_X_HUB_SIGNATURE' => 'foo' })
    assert_response :forbidden
  end

  test 'POST #receive responds :ok for a valid request' do
    send_webhook(payload: { foo: 'bar' })
    assert_response :ok
  end

  GitHub::WebHook::ACCEPTED_EVENTS.map do |event|
    test "#receive queues a job for the #{event} event" do
      # ping_event_job -> PingEventJob
      job = "#{event}_event_job".classify.constantize

      assert_enqueued_with(job: job, queue: 'github_event') do
        send_webhook(payload: { foo: 'bar' }, headers: { 'HTTP_X_GITHUB_EVENT' => event })
      end
    end
  end

  private

  def send_webhook(payload: {}, headers: {})
    default_user_agent = { 'User-Agent' => 'GitHub-Hookshot/6b02022' }
    default_signature  = { 'HTTP_X_HUB_SIGNATURE' => "sha1=#{GitHub::WebHook.generate_hmac(payload.to_json)}" }

    headers = headers.merge(default_user_agent) unless headers.key?('User-Agent')
    headers = headers.merge(default_signature) unless headers.key?('HTTP_X_HUB_SIGNATURE')

    post github_hooks_path, params: payload, headers: headers, as: :json
  end
end
