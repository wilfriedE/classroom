# frozen_string_literal: true
module FixturesHelper
  # Public: Read a JSON file from the test/fixtures/files/github_webhook_events
  # folder and return the payload.
  #
  # event - The String or Symbol file that maps to the event.
  #
  # Examples:
  #
  #   github_webhook_event('ping')
  #   #=> {"zen"=>"Responsive is better than fast.",
  #     ...
  #   }
  #
  #   github_webhook_event('repository/deleted')
  #   #=> {"action" => "deleted"
  #     ...
  #   }
  #
  # Returns an ActiveSupport::HashWithIndifferentAccess instance.
  def github_webhook_event(event)
    file_path = "github_webhook_events/#{event}.json"
    JSON.parse(file_fixture(file_path).read).with_indifferent_access
  end
end
