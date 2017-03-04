# frozen_string_literal: true
require 'webmock/minitest'

# From Octokit.rb
# https://github.com/octokit/octokit.rb/blob/master/spec/helper.rb
def github_url(url)
  return url if url.match?(/^http/)

  url = File.join(Octokit.api_endpoint, url)
  uri = Addressable::URI.parse(url)
  uri.path.gsub!('v3//', 'v3/')

  uri.to_s
end

# Public: Stub a GitHub http request.
#
# Examples:
#
#   stub_github_get("/users/tarebyte")
#
# Returns nothing.
ActionDispatch::Routing::HTTP_METHODS.map do |http_method|
  define_method("stub_github_#{http_method}") do |url|
    stub_request(http_method, github_url(url))
  end
end
