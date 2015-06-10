module LobbyBoy
  class SessionController < ActionController::Base
    layout false

    def check
      response.headers['X-Frame-Options'] = 'SAMEORIGIN'
    end

    def state
      id_token = self.id_token

      if id_token
        puts "ID token expires in #{id_token.expires_in} seconds at #{id_token.expires_at}."

        render text: 'authenticated', status: 200
      else
        render text: 'unauthenticated', status: 401
      end
    end

    def end
      cookies.delete :oidc_rp_state, domain: LobbyBoy.client.cookie_domain

      url = LobbyBoy::Util::URI.add_query_params LobbyBoy.client.end_session_endpoint,
                                                 script: 'true'

      redirect_to url
    end

    def refresh
      provider = LobbyBoy.provider.name

      id_token = self.id_token

      id_token_hint = id_token && id_token.jwt_token
      origin = '/session/state'

      params = {
          prompt: 'none',
          origin: origin,
          id_token_hint: id_token_hint
      }

      redirect_to "#{omniauth_prefix}/#{provider}?#{compact_hash(params).to_query}"
    end

    ##
    # Defines used functions. All of which are only dependent on
    # their input parameters and not on some random global state.
    module Functions
      module_function

      ##
      # Returns a new hash only containing entries the values of which are not nil.
      def compact_hash(hash)
        hash.reject { |_, v| v.nil? }
      end

      def omniauth_prefix
        ::OmniAuth.config.path_prefix
      end
    end

    module InstanceMethods
      def id_token
        token = session['lobby_boy.id_token']
        ::LobbyBoy::OpenIDConnect::IdToken.new token if token
      end
    end

    include Functions
    include InstanceMethods
  end
end
