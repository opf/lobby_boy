require 'omniauth/strategies/openid_connect'
require 'lobby_boy/openid_connect/id_token'
require 'lobby_boy/util/uri'

module AuthorizeUriParameters
  ##
  # Always append 'prompt=none' to every authorization request to make the login
  # automatic if possible.
  def authorize_uri
    LobbyBoy::Util::URI.add_query_params super,
                                         prompt: request.params['prompt'] || 'none',
                                         id_token_hint: request.params['id_token_hint']
  end

  def access_token
    super.tap do |at|
      session_state = request.params['session_state']
      id_token = ::LobbyBoy::OpenIDConnect::IdToken.new at.id_token
      env['lobby_boy.id_token'] = id_token

      if session_state
        cookie = {
            state: session_state,
            expires_at: id_token.exp
        }

        env['lobby_boy.cookie'] = {
            value: cookie.to_json,
            expires: id_token.expires_in.seconds.from_now,
            domain: LobbyBoy.client.cookie_domain
        }
      end
    end
  end
end

OmniAuth::Strategies::OpenIDConnect.prepend AuthorizeUriParameters
