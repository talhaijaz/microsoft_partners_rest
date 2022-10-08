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
      url = login_url + "#{config.tenant_id}/oauth2/token"
      client.post_api_data(url, body)
    end

  end
end
