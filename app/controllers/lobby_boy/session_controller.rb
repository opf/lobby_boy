module LobbyBoy
  class SessionController < ActionController::Base
    layout false

    def check
      response.headers['X-Frame-Options'] = 'SAMEORIGIN'

      render 'check', locals: { state: 'init' }
    end

    def state
      current_state =
        if params[:state] == 'unauthenticated'
          'unauthenticated'
        elsif params[:state] == 'logout'
          'logout'
        else
          self.id_token ? 'authenticated' : 'unauthenticated'
        end

      render 'check', locals: { state: current_state }
    end

    def end
      cookies.delete :oidc_rp_state, domain: LobbyBoy.client.cookie_domain

      redirect_to LobbyBoy.client.end_session_endpoint
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
