# frozen_string_literal: true
OmniAuth.config.test_mode = true

OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
  'provider'    => 'github',
  'uid'         => 42,
  'extra'       => { 'raw_info' => { 'site_admin' => false } },
  'credentials' => { 'token' => SecureRandom.hex(20) }
)

module SignInHelper
  # rubocop:disable AbcSize
  def sign_in_as(user)
    OmniAuth.config.mock_auth[:github].uid = user.uid
    OmniAuth.config.mock_auth[:github].extra.raw_info.site_admin = user.site_admin
    OmniAuth.config.mock_auth[:github].credentials.token = user.token

    post '/auth/github/callback'
  end
  # rubocop:enable AbcSize
end
