# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

Dir[Rails.root.join('test', 'support', '**', '*.rb')].each { |f| require f }

class ActiveSupport::TestCase
  include Chewy::Minitest::Helpers

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # https://gist.github.com/mattbrictson/72910465f36be8319cde
  # Monkey patch the `test` DSL to enable VCR and configure a cassette named
  # based on the test method. This means that a test written like this:
  #
  # class OrderTest < ActiveSupport::TestCase
  #   test "user can place order" do
  #     ...
  #   end
  # end
  #
  # will automatically use VCR to intercept and record/play back any external
  # HTTP requests using `cassettes/order_test/_user_can_place_order.json`.
  #
  # This also wraps all tests in the Chewy `:bypass` strategy.
  #
  # rubocop:disable MethodLength
  def self.test(test_name, &block)
    return super if block.nil?

    cassette = [name, test_name].map do |str|
      str.underscore.gsub(/[^\w]+/i, '_')
    end.join('/')

    super(test_name) do
      VCR.use_cassette(cassette) do
        Chewy.strategy(:bypass) do
          instance_eval(&block)
        end
      end
    end
  end
end

class ActionDispatch::IntegrationTest
  include SignInHelper
end
