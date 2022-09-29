module MicrosoftPartnersRestApi
  class AccessToken
    attr_reader :config, :login_url, :body

    def initialize(body, client = MicrosoftPartnersRestApi.client)
      @config = MicrosoftPartnersRestApi.config
      @login_url = 'https://login.microsoftonline.com/'
      @body = body
    end

    def fetch
      url = login_url + "#{config.tenant_id}/oauth2/token"
      begin
        response = RestClient.post(url, body)
        OpenStruct.new({ code: response.code, body: JSON(response.body) })
      rescue StandardError => e
        handle_exception(e)
      end
    end

    def handle_exception(exception)
      OpenStruct.new({ code: exception.http_code, body: 'Invalid params' })
    end
  end
end
