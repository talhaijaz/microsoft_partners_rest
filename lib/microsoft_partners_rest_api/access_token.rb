module MicrosoftPartnersRestApi
  class AccessToken
    attr_reader :config, :login_url, :body, :client

    def initialize(body, client = MicrosoftPartnersRestApi.client)
      @config = MicrosoftPartnersRestApi.config
      @login_url = 'https://login.microsoftonline.com/'
      @body = body
      @client = client
    end

    def fetch
      body[:resource] = 'https://api.partnercenter.microsoft.com'
      if body[:code].present?
        body[:grant_type] = 'authorization_code'
      elsif body[:refresh_token].present?
        body[:grant_type] = 'refresh_token'
      else
        body[:resource] = 'https://graph.windows.net'
        body[:grant_type] = 'client_credentials'
      end

      url = login_url + "#{config.tenant_id}/oauth2/token"
      client.post_api_data(url, body)
    end

  end
end
